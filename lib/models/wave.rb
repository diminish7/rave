# Represents a Wave
module Rave
  module Models
    class Wave
      attr_reader :id, :wavelet_ids
      
      #Options include:
      # - :wavelet_ids
      # - :context
      # - :id
      def initialize(options = {})
        @id = options[:id]
        @wavelet_ids = Set.new(options[:wavelet_ids])
        @context = options[:context]
      end
      
    end
  end
end