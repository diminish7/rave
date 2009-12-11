module Rave
  module Models
    # A wave or wave component.
    # This is a virtual class.
    class Component
      GENERATED_PREFIX = 'TBD' # :nodoc: Prefixes blips and wavelets that are created by the robot.

      # LOGGER.warning(str), LOGGER.severe(str) and LOGGER.info(str) to log strings at appstore.
      LOGGER = java.util.logging.Logger.getLogger("Component")
      
      attr_writer :context # :nodoc: Allow context to set link to it.

      # ID [String]
      attr_reader :id
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
