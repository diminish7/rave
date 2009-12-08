module Rave
  module Models
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