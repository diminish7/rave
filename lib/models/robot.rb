require 'singleton'
require 'yaml'

module Rave
  module Models
    # Contains Robot data, event handlers and cron jobs.
    class Robot < User
      include Rave::Mixins::DataFormat
      include Rave::Mixins::Controller
      include Singleton

      CONFIG_FILE = 'config.yaml' # :nodoc:
      
      # Version of the robot, as in the yaml config [String]
      def version # :nodoc:
        @version.dup
      end
      
      def initialize() # :nodoc:
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
      
      # Register a handler. Multiple handlers may be applied to a single event.
      # +event_type+:: Must be one of Rave::Models::Event::*::TYPE [String]
      def register_handler(event_type, handler)
        raise Rave::InvalidEventException.new("Unknown event: #{event_type}") unless Rave::Models::Event.valid_type?(event_type)
        raise Rave::InvalidHandlerException.new("Unknown handler: #{handler}") unless self.respond_to?(handler)
        @handlers[event_type] ||= []
        @handlers[event_type] << handler unless @handlers[event_type].include?(handler)
      end
      
      #Dispatches events to the appropriate handler
      def handle_event(event, context) # :nodoc:
        #Ignore unhandled events
        if (handlers = @handlers[event.type])
          handlers.each do |handler|
            self.send(handler, event, context)
          end
        end
        nil
      end
      
      #Registers a cron job
      def register_cron_job(handler, seconds)
        @cron_jobs << { :path => "/_wave/cron/#{handler}", :handler => handler, :seconds => seconds }
        nil
      end

      # Creates a new wave with initial participants set.
      # +participants+:: Humans and/or robots to start in the new wave [Array of String/User]
      # Returns: The new wave, which contains a root wavelet which itself contains a root blip [Wave]
      def create_wavelet(participants)
        @context.create_wavelet(participants)
      end
      
    protected
      #Register any handlers that are defined through naming convention
      def register_default_handlers # :nodoc:
        Event.types.each do |type|
          listener = type.downcase.to_sym
          if respond_to?(listener)
            register_handler(type, listener)
          end
        end
      end
    end
  end
end