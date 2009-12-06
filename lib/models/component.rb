# A model component that exists within the context.
module Rave
  module Models
    class Component
      GENERATED_PREFIX = 'TBD' # :nodoc:

      LOGGER = java.util.logging.Logger.getLogger("Component")

      attr_reader :id # Unique identifier
      attr_writer :context # :nodoc: Allow context to set link to it.
      
      def initialize(options = {})
        @id = options[:id] or raise ArgumentError.new(":id option is required")
        @context = options[:context]
      end
    end
  end
end
