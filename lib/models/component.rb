# A model component that exists within the context.
module Rave
  module Models
    class Component
      GENERATED_PREFIX = 'TBD' # :nodoc:

      LOGGER = java.util.logging.Logger.getLogger("Component")

      attr_writer :context # :nodoc: Allow context to set link to it.

      def id; @id.dup; end
      
      def initialize(options = {})
        @id = options[:id] or raise ArgumentError.new(":id option is required for #{self.class.name}")
        @context = options[:context]
      end

      # Convert to string, showing class name and ID.
      def to_s
        "#{self.class.name[/[^:]*$/]}:#{@id}"
      end
    end
  end
end
