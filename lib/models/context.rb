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
        @waves.values.each { |wave| wave.context = self }          #Set up self as this wave's context
        @wavelets = options[:wavelets] || {}
        @wavelets.values.each { |wavelet| wavelet.context = self } #Set up self as this wavelet's context
        @blips = options[:blips] || {}
        @blips.values.each { |blip| blip.context = self }          #Set up self as this blip's context
        @operations = options[:operations] || []
      end
      
      #Find the root wavelet if it exists in this context
      def root_wavelet
        @wavelets.values.find { |wavelet| wavelet.id =~ Regexp.new(Rave::Models::Wavelet::ROOT_ID_REGEXP) }
      end
      
      #Serializes the context to JSON format
      def to_json
        self.to_hash.to_json
      end
      
      #Serialize the context to a hash map
      def to_hash
        hash = {
          'operations' => { 'javaClass' => 'java.util.ArrayList', 'list' => [] },
          'javaClass' => 'com.google.wave.api.impl.OperationMessageBundle'
         }
        @operations.each do |op|
          hash['operations']['list'] << op.to_hash
        end
        hash
      end
    end
  end
end