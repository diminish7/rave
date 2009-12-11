module Rave
  module Models
    # An annotation applying styling or other meta-data to a section of text.
    class Annotation  
      def name; @name.dup; end
      def value; @value.dup; end
      def range; @range.dup; end

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