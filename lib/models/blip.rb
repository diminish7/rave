#Represents a Blip, owned by a Wavelet
module Rave
  module Models
    class Blip
      attr_reader :id, :annotations, :child_blip_ids, :content, :contributors, :creator,
                  :elements, :last_modified_time, :parent_blip_id, :version, :wave_id, :wavelet_id
      attr_accessor :context
      
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
        @id = options[:id]
        @context = options[:context]
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
      
    end
  end
end