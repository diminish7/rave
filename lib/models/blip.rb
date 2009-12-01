#Represents a Blip, owned by a Wavelet
module Rave
  module Models
    class Blip
      JAVA_CLASS = 'com.google.wave.api.impl.BlipData' # :nodoc:
      
      attr_reader :id, :annotations, :child_blip_ids, :content, :contributors, :creator,
                  :elements, :last_modified_time, :parent_blip_id, :version, :wave_id, :wavelet_id
      attr_accessor :context
      
      @@next_id = 1 # Unique ID for newly created blips.
      
      #Options include:
      # - :annotations
      # - :child_blip_ids
      # - :content
      # - :contributors
      # - :creator
      # - :elements
      # - :last_modified_time
      # - :parent_blip_id
      # - :version
      # - :wave_id
      # - :wavelet_id
      # - :id
      # - :context
      def initialize(options = {})
        @annotations = options[:annotations] || []
        @child_blip_ids = Set.new(options[:child_blip_ids])
        @content = options[:content] || ''
        @contributors = Set.new(options[:contributors])
        @creator = options[:creator]
        @elements = options[:elements] || {}
        @last_modified_time = options[:last_modified_time] || Time.now
        @parent_blip_id = options[:parent_blip_id]
        @version = options[:version] || -1
        @wave_id = options[:wave_id]
        @wavelet_id = options[:wavelet_id]
        @context = options[:context]
        
        # If the blip doesn't have a defined ID, since we just created it,
        # assign a temporary, though unique, ID, based on the ID of the wavelet.
        @id = if options[:id].nil?
          id = "TBD_#{@wavelet_id}_#{@@next_id}"
          @@next_id += 1
          id
        else
          options[:id]
        end
      end
      
      #Returns true if this is a root blip (no parent blip)
      def root?
        @parent_blip_id.nil?
      end
      
      #Returns true if an annotation with the given name exists in this blip
      def has_annotation?(name)
        @annotations.any? { |a| a.name == name }
      end
      
      #Creates a child blip under this blip
      def create_child_blip
        #TODO
      end
      
      #Delete this blip from its wavelet
      def delete
        #TODO
      end

      # Wavelet that the blip is a part of.
      def wavelet
        @context.wavelets[@wavelet_id]
      end
      
      # Convert to json for sending in an operation. We should never need to
      # send more data than this, although blips we receive will have more data.
      def to_json
        {
          'blipId' => @id,
          'javaClass' => JAVA_CLASS,
          'waveId' => @wave_id,
          'waveletId' => @wavelet_id
        }.to_json
      end
    end
  end
end
