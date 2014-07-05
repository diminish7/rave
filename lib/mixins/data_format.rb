#This mixin provides methods for robots to deal with parsing and presenting JSON and XML
module Rave
  module Mixins
    module DataFormat
      include Logger

      PROFILE_JAVA_CLASS = 'com.google.wave.api.ParticipantProfile'

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
                xml.tag!("w:cron", "path" => job[:path], "timerinseconds" => job[:seconds])
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
          'name' => @name,
          'imageUrl' => @image_url,
          'profileUrl' => @profile_url,
          'javaClass' => PROFILE_JAVA_CLASS,
        }.to_json.gsub('\/','/')
      end

      #Parses context and event info from JSON input
      def parse_json_body(json)
        logger.info("Received:\n#{json.to_s}")
        data = JSON.parse(json)
        #Create Context
        context = context_from_json(data)
        #Create events
        events = events_from_json(data, context)
        logger.info("Structure (before):\n#{context.print_structure}")
        logger.info("Events: #{events.map { |e| e.type }.join(', ')}")
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
              :blips => blips,
              :robot => self
          )
      end

      def blips_from_json(json)
        map_to_hash(json['blips']).values.collect do |blip_data|
          Rave::Models::Blip.new(
                :id => blip_data['blipId'],
                :annotations => annotations_from_json(blip_data),
                :child_blip_ids => list_to_array(blip_data['childBlipIds']),
                :content => blip_data['content'],
                :contributors => list_to_array(blip_data['contributors']),
                :creator => blip_data['creator'],
                :elements => elements_from_json(blip_data['elements']),
                :last_modified_time => blip_data['lastModifiedTime'],
                :parent_blip_id => blip_data['parentBlipId'],
                :version => blip_data['version'],
                :wave_id => blip_data['waveId'],
                :wavelet_id => blip_data['waveletId']
            )
        end
      end

      def elements_from_json(elements_map)
        elements = {}

        map_to_hash(elements_map).each_pair do |position, data|
          elements[position.to_i] = Element.create(data['type'], map_to_hash(data['properties']))
        end

        elements
      end

      # Convert a json-java list (which may not be defined) into an array.
      # Defaults to an empty array.
      def list_to_array(list)
        if list.nil?
          []
        else
          list['list'] || []
        end
      end

      # Convert a json-java map (which may not be defined) into a hash. Defaults
      # to an empty hash.
      def map_to_hash(map)
        if map.nil?
          {}
        else
          map['map'] || {}
        end
      end

      def annotations_from_json(json)
        list_to_array(json['annotation']).collect do |annotation|
          Rave::Models::Annotation.create(
            annotation['name'],
            annotation['value'],
            range_from_json(annotation['range'])
          )

        end
      end

      def range_from_json(json)
         Range.new(json['start'], json['end'])
      end

      def events_from_json(json, context)
        list_to_array(json['events']).collect do |event|
          properties = {}
          event['properties']['map'].each do |key, value|
            properties[key] = case value
            when String # Just a string, as in blipId.
              value
            when Hash # Serialised array, such as in participantsAdded.
              value['list']
            else
              raise "Unrecognised property #{value} #{value.class}"
            end
          end
          Rave::Models::Event.create(event['type'],
                :timestamp => event['timestamp'],
                :modified_by => event['modifiedBy'],
                :properties => properties,
                :context => context,
                :robot => self
             )
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
                  :data_documents => map_to_hash(wavelet['dataDocuments']),
                  :last_modifed_time => wavelet['lastModifiedTime'],
                  :participants => list_to_array(wavelet['participants']),
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
