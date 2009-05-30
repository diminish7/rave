# Represents a Wave
module Rave
  module Models
    class Wave
      attr_reader :id, :wavelet_ids
      
      #Options include:
      # - :id
      # - :wavelet_ids
      def initialize(options = {})
        @id = options[:id]
        @wavelet_ids = Set.new(options[:wavelet_ids])
      end
      
    end
  end
end