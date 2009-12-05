require 'singleton'
require 'yaml'

#Contains Robot data, event handlers and cron jobs
module Rave
  module Models
    class Robot < User
      include Rave::Mixins::DataFormat
      include Rave::Mixins::Controller
      include Singleton

      CONFIG_FILE = 'config.yaml' # :nodoc:
      
      attr_reader :version # Version of the robot, as in the yaml config.
      
      def initialize()
        config = config_from_file
        super(config)
        @handlers = {}
        @cron_jobs = []
        @version = config[:version] || '1'
        register_default_handlers
      end

      # Read options from user-edited yaml config file.
      def config_from_file # :nodoc:
        config = YAML::load(File.open(CONFIG_FILE))
        hash = {}
        config['robot'].each_pair { |k, v| hash[k.to_sym] = v }
        hash
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
      def register_cron_job(handler, seconds)
        @cron_jobs << { :path => "/_wave/cron/#{handler}", :handler => handler, :seconds => seconds }
      end
      
    protected
      #Register any handlers that are defined through naming convention
      def register_default_handlers
        Event::EVENT_CLASSES.each do |event|
          listener = event.type.downcase.to_sym
          if respond_to?(listener)
            register_handler(event.type, listener)
          end
        end
      end
    end
  end
end