#This mixin provides methods for robots to deal with parsing and presenting JSON and XML
module Rave
  module Mixins
    module DataFormat
      
      LOGGER = java.util.logging.Logger.getLogger("DataFormat") unless defined?(LOGGER)
      
      #Returns this robot's capabilities in XML
      def capabilities_xml
        xml = Builder::XmlMarkup.new
        xml.instruct!
        xml.tag!("w:robot", "xmlns:w" => "http://wave.google.com/extensions/robots/1.0") do
          xml.tag!("w:version", @version)
          xml.tag!("w:capabilities") do
            @handlers.keys.each do |capability|
              xml.tag!("w:capability", "name" => capability)
            end  
          end
          unless @cron_jobs.empty?
            xml.tag!("w:crons") do
              @cron_jobs.each do |job|
                xml.tag!("w:cron", "path" => job[:path], "timeinseconds" => job[:seconds])
              end
            end
          end
          attrs = { "name" => @name }
          attrs["imageurl"] = @image_url if @image_url
          attrs["profileurl"] = @profile_url if @profile_url
          xml.tag!("w:profile", attrs)
        end
      end
      
      #Returns the robot's profile in json format
      def profile_json
        {
          "name" => @name,
          "imageurl" => @image_url,
          "profile_url" => @profile_url
        }.to_json.gsub('\/','/')
      end
      
      #Parses context and event info from JSON input
      def parse_json_body(json)
        LOGGER.info("Parsing JSON:")
        LOGGER.info(json.to_s)
        data = JSON.parse(json)
        #Create Context
        context = context_from_json(data)
        #Create events
        events = events_from_json(data)
        return context, events
      end
      
    protected
      def context_from_json(json)
        blips = {}
        blips_from_json(json).each do |blip|
          blips[blip.id] = blip
        end
        wavelets = {}
        wavelets_from_json(json).each do |wavelet|
          wavelets[wavelet.id] = wavelet
        end
        waves = {}
        #Waves aren't sent back, but we can reconstruct them from the wavelets
        waves_from_wavelets(wavelets).each do |wave|
          waves[wave.id] = wave
        end
        Rave::Models::Context.new(
              :waves => waves,
              :wavelets => wavelets,
              :blips => blips
          )
      end
      
      def blips_from_json(json)
        if json['blips']
          json['blips']['map'].values.collect do |blip_data|
            blip = Rave::Models::Blip.new(
                  :id => blip_data['blipId'],
                  :annotations => annotations_from_json(blip_data),
                  :child_blip_ids => blip_data['childBlipIds'],
                  :content => blip_data['content'],
                  :contributors => blip_data['contributors'],
                  :creator => blip_data['creator'],
                  :elements => blip_data['elements'],
                  :last_modified_time => blip_data['lastModifiedTime'],
                  :parent_blip_id => blip_data['parentBlipId'],
                  :version => blip_data['version'],
                  :wave_id => blip_data['waveId'],
                  :wavelet_id => blip_data['waveletId']
              )
          end
        else
          []
        end
      end
      
      def annotations_from_json(json)
        if json['annotation'] && json['annotations']['list']
          json['annotations']['list'].collect do |annotation|
            Rave::Models::Annotation.new(
                  :name => annotation['name'], 
                  :value => annotation['value'], 
                  :range => Range.new(annotation['range']['start'], annotation['range']['end'])
              )
          end
        else
          []
        end
      end
      
      def events_from_json(json)
        if json['events'] && json['events']['list']
          json['events']['list'].collect do |event|
            properties = {}
            event['properties']['map'].each { |key, value| properties[key] = value['list'] }
            Rave::Models::Event.new(
                  :type => event['type'],
                  :timestamp => event['timestamp'],
                  :modified_by => event['modifiedBy'],
                  :properties => properties
               )
          end
        else
          []
        end
      end
      
      def wavelets_from_json(json)
        #Currently only one wavelet is sent back
        #TODO: should this look at the wavelet's children too?
        wavelet = json['wavelet']
        if wavelet
          [
            Rave::Models::Wavelet.new(
                  :creator => wavelet['creator'],
                  :creation_time => wavelet['creationTime'],
                  :data_documents => wavelet['dataDocuments'],
                  :last_modifed_time => wavelet['lastModifiedTime'],
                  :participants => wavelet['participants'],
                  :root_blip_id => wavelet['rootBlipId'],
                  :title => wavelet['title'],
                  :version => wavelet['version'],
                  :wave_id => wavelet['waveId'],
                  :id => wavelet['waveletId']
              )
          ]
        else
          []
        end
      end
      
      def waves_from_wavelets(wavelets)
        wave_wavelet_map = {}
        if wavelets
          wavelets.values.each do |wavelet|
            wave_wavelet_map[wavelet.wave_id] ||= []
            wave_wavelet_map[wavelet.wave_id] << wavelet.id
          end
        end
        wave_wavelet_map.collect do |wave_id, wavelet_ids|
          Rave::Models::Wave.new(:id => wave_id, :wavelet_ids => wavelet_ids)
        end
      end
      
    end
  end
end