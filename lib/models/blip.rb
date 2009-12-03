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
        @child_blip_ids = options[:child_blip_ids] || []
        @content = options[:content] || ''
        @contributors = options[:contributors] || []
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
        blip = Blip.new(:wave_id => @wave_id, :parent_blip_id => @id, :wavelet_id => @wavelet_id, :context => @context)
        @context.operations << Operation.new(:type => Operation::BLIP_CREATE_CHILD, :blip_id => @id, :wave_id => @wave_id, :wavelet_id => @wavelet_id, :property => blip)
        add_child_blip(blip)
        blip
      end

      # Adds a created child blip to this blip.
      def add_child_blip(blip) # :nodoc:
        @child_blip_ids << blip.id
        @context.add_blip(blip)
      end

      # List of direct children of this blip. The first one will be continuing
      # the thread, others will be indented replies.
      def child_blips
        @child_blip_ids.map { |id| @context.blips[id] }
      end
      
      #Delete this blip from its wavelet
      def delete
        #TODO
      end
      
      # Wavelet that the blip is a part of.
      def wavelet
        @context.wavelets[@wavelet_id]
      end

      def wave
        @context.waves[@wave_id]
      end

      # Blip that this Blip is a direct reply to. Will be nil if the root blip
      # in a wavelet.
      def parent_blip
        @context.blips[@parent_blip_id]
      end

      def print_structure(indent = 0) # :nodoc:
        text = @content.gsub(/\n/, "\\n")
        text = text.length > 24 ? "#{text[0..20]}..." : text
        text.gsub(/\n/, "\\n")
        str = ''
        str << "#{'  ' * indent}Blip:#{@id}:#{@contributors.join(',')}:#{text}\n"
        
        children = child_blips

        # All children, except the first, should be indented.
        children.each_with_index do |blip, index|
          # Gap between reply chains.
          if index > 1
            str << "\n"
          end

          if index > 0
            str << blip.print_structure(indent + 1)
          end
        end

        if children[0]
          str << children[0].print_structure(indent)
        end

        str
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
