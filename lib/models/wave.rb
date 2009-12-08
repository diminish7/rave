# Represents a Wave
module Rave
  module Models
    class Wave < Component
      def wavelet_ids; @wavelet_ids.map { |id| id.dup }; end
      
      #Options include:
      # - :wavelet_ids
      # - :id
      def initialize(options = {})
        super(options)
        @wavelet_ids = Set.new(options[:wavelet_ids])
      end

      def wavelets
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
