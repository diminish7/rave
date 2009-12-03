#Contains server request information including current waves and operations
module Rave
  module Models
    class Context
      attr_reader :waves, :wavelets, :blips, :operations, :users
      
      JAVA_CLASS = 'com.google.wave.api.impl.OperationMessageBundle' # :nodoc:
      
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
        @users = options[:users] || {}
        @users.values.each { |user| user.context = self }          #Set up self as this user's context
      end
      
      # Add a blip to blips (Use an Operation to actually add the blip to the Wave).
      def add_blip(blip) # :nodoc:
        @blips[blip.id] = blip
        blip.context = self
        blip
      end
      
      #Find the root wavelet if it exists in this context
      def root_wavelet
        @wavelets.values.find { |wavelet| wavelet.id =~ Regexp.new(Rave::Models::Wavelet::ROOT_ID_REGEXP) }
      end
           
      #Serialize the context for use in the line protocol.
      def to_json
        hash = {
          'operations' => { 'javaClass' => 'java.util.ArrayList', 'list' => @operations },
          'javaClass' => JAVA_CLASS
        }
        hash.to_json
      end

      def print_structure(indent = 0) # :nodoc:
        str = ''
        waves.each_value do |wave|
          str << wave.print_structure(indent)
        end
        str
      end
    end
  end
end
