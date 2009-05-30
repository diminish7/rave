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
        @wavelets.values.find { |wavelet| wavelet.id =~ Rave::Constants::ROOT_WAVELET_ID_SUFFIX }
      end
      
    end
  end
end