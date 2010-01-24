module Rave
  module Models
    # A wave or wave component.
    # This is an abstract class.
    class Component
      include Rave::Mixins::Logger
      
      GENERATED_PREFIX = 'TBD' # :nodoc: Prefixes blips and wavelets that are created by the robot.
      GENERATED_PATTERN = /^#{GENERATED_PREFIX}/ # :nodoc:

      @@last_id = 0 # For generated components, this is a unique ID number for them.
      
      attr_writer :context # :nodoc: Allow context to set link to it.

      # Has this component been generated by the robot [Boolean]
      def generated? # :nodoc:
        # This is true for all components except Users, who would override this.
        not (@id =~ /^#{GENERATED_PREFIX}/).nil?
      end

      # Generate a unique id number (from 1) [Integer]
      def unique_id # :nodoc:
        @@last_id += 1
      end

      # ID [String]
      def id # :nodoc:
        @id.dup
      end
      
      def initialize(options = {}) # :nodoc:
        @id = options[:id] or raise ArgumentError.new(":id option is required for #{self.class.name}")
        @context = options[:context]
      end

      # Convert to string.
      def to_s
        "#{self.class.name[/[^:]*$/]}:#{@id}"
      end
    end
  end
end
