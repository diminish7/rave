#Contains Robot data, event handlers and cron jobs
module Rave
  module Models
    class Robot
      attr_reader :name, :image_url, :profile_url
      
      #Options include:
      # - :name
      # - :image_url
      # - :profile_url
      def initialize(options = {})
        @name = options[:name]
        @image_url = options[:image_url]
        @profile_url = options[:profile_url]
        @handlers = {}
        @cron_jobs = []
      end
      
      #Register a handler
      # event_type is a string, and must be one of Rave::Models::Event::VALID_EVENTS
      # multiple handlers may be applied to an event
      def register_handler(event_type, handler)
        raise Rave::InvalidEventException.new("Unknown event: #{event_type}") unless Rave::Models::Event.valid_event_type?(event_type)
        raise Rave::InvalidHandlerException.new("Unknown handler: #{handler}") unless self.respond_to?(handler)
        @handlers[event_type] ||= []
        @handlers[event_type] << handler unless @handlers[event_type].include?(handler)
      end
      
      #Dispatches events to the appropriate handler
      def handle_event(event, context)
        #Ignore unhandled events
        if (handlers = @handlers[event.type])
          handlers.each do |handler|
            self.send(handler, event, context)
          end
        end
      end
      
      #Registers a cron job
      def register_cron_job(path, seconds)
        @cron_jobs << {:path => path, :seconds => seconds}
      end
      
      #Returns this robot's capabilities in XML
      def capabilities_xml
        xml = Builder::XmlMarkup.new
        xml.instruct!
        xml.tag!("w:robot", "xmlns:w" => "http://wave.google.com/extensions/robots/1.0") do
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
      
      
      
    end
  end
end