#Contains server request information including current waves and operations
module Rave
  module Models
    class Context
      attr_reader :waves, :wavelets, :blips, :operations
      
      #Options include:
      # - :waves
      # - :wavelets
      # - :blips
      # - :operations
      def initialize(options = {})
        @waves = options[:waves] || {}
        @wavelets = options[:wavelets] || {}
        @blips = options[:blips] || {}
        @operations = options[:operations] || []
      end
      
      #Find the root wavelet if it exists in this context
      def root_wavelet
        @wavelets.values.find { |wavelet| wavelet.id =~ Regexp.new(Rave::Models::Wavelet::ROOT_ID_REGEXP) }
      end
      
      #Add a new operation to the queue
      def add_operation
        #TODO
      end
      
    end
  end
end