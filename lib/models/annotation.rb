module Rave
  module Models
    # An annotation applying styling or other meta-data to a section of text.
    class Annotation
      # Name of the annotation type [String]
      attr_reader :name
      def name # :nodoc:
        @name.dup
      end

      # Value of the annotation [String]
      attr_reader :value
      def value # :nodoc:
        @value.dup
      end

      # Range of characters over which the annotation applies [Range]
      attr_reader :range
      def range # :nodoc:
        @range.dup
      end

      #Options include
      # - :name
      # - :value
      # - :range
      def initialize(options = {})
        @name = options[:name]
        @value = options[:value]
        @range = options[:range]
      end
    end
  end
end