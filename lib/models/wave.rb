# Represents a Wave
module Rave
  module Models
    class Wave
      include Rave::Mixins::UniqueId
      
      attr_reader :id, :wavelet_ids
      
      #Options include:
      # - :wavelet_ids
      # - :context
      def initialize(options = {})
        generate_id
        @wavelet_ids = Set.new(options[:wavelet_ids])
        @context = options[:context]
      end
      
      #Creates a new wavelet belonging to this wave
      def create_wavelet
        #TODO
      end
      
    end
  end
end