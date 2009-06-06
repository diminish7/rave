module Rave
  module Models
    class Annotation
        attr_reader :name, :value, :range
        
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