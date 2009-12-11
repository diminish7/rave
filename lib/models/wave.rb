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
        super(options)
        @wavelet_ids = Set.new(options[:wavelet_ids])
      end

      # All wavelets that are part of the wave [Array of Wavelet]
      attr_reader :wavelets
      def wavelets # :nodoc:
        @wavelet_ids.map { |id| @context.wavelets[id] }
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
