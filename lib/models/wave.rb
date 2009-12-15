module Rave
  module Models
    # Represents a Wave
    class Wave < Component
      # IDs for all wavelets that are part of the wave [Array of String]
      def wavelet_ids # :nodoc:
        @wavelet_ids.map { |id| id.dup }
      end
      
      #Options include:
      # - :wavelet_ids
      # - :id
      def initialize(options = {}) # :nodoc:
        if options[:id].nil? and options[:context]
          super(:id => "#{GENERATED_PREFIX}_wave_#{unique_id}", :context => options[:context])
        else
          super(options)
        end

        @wavelet_ids = options[:wavelet_ids] || []
      end

      # All wavelets that are part of the wave [Array of Wavelet]
      attr_reader :wavelets
      def wavelets # :nodoc:
        @wavelet_ids.map { |id| @context.wavelets[id] }
      end

      # The root wavelet (it will be nil if the event refers to a private subwavelet) [Wavelet]
      attr_reader :root_wavelet
      def root_wavelet # :nodoc:
        wavelets.find { |wavelet| wavelet and wavelet.root? }
      end

      def print_structure(indent = 0) # :nodoc:
        str = ''
        str << "#{'  ' * indent}Wave:#{@id}\n"

        wavelets.each do |wavelet|
          str << wavelet.print_structure(indent + 1)
        end

        str
      end
    end
  end
end
