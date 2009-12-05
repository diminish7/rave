# Represents a Wavelet, owned by a Wave
module Rave
  module Models
    class Wavelet < Component
      attr_reader :creator, :creation_time, :data_documents, :last_modified_time, 
                  :participants, :root_blip_id, :title, :version, :wave_id
      
      ROOT_ID_SUFFIX = "conv+root"   #The suffix for the root wavelet in a wave]
      ROOT_ID_REGEXP = /conv\+root$/
      
      # Options include:
      # - :creator
      # - :creation_time 
      # - :data_documents
      # - :last_modifed_time
      # - :participants
      # - :root_blip_id
      # - :title
      # - :version
      # - :wave_id
      # - :context
      # - :id
      def initialize(options = {})
        super(options)
        @creator = options[:creator]
        @creation_time = options[:creation_time] || Time.now
        @data_documents = options[:data_documents] || {}
        @last_modified_time = options[:last_modified_time] || Time.now
        @participants = options[:participants] || []
        @root_blip_id = options[:root_blip_id]
        @title = options[:title]
        @version = options[:version] || 0
        @wave_id = options[:wave_id]
      end
      
      #Creates a blip for this wavelet
      def create_blip
        parent = final_blip
        blip = Blip.new(:wave_id => @wave_id, :parent_blip_id => parent.id, :wavelet_id => @id, :context => @context)
        parent.add_child_blip(blip)
        
        @context.operations << Operation.new(:type => Operation::WAVELET_APPEND_BLIP, :wave_id => @wave_id, :wavelet_id => @id, :property => blip)
        blip
      end

      # Find the last blip in the main thread.
      def final_blip
        blip = @context.blips[@root_blip_id]
        if blip
          while not blip.child_blips.empty?
            blip = blip.child_blips.first
          end
        end
        blip
      end
      
      #Adds a participant to the wavelet
      def add_participant(participant_id)
        @context.operations << Operation.new(:type => Operation::WAVELET_ADD_PARTICIPANT, :wave_id => @wave_id, :wavelet_id => @id, :property => participant_id)
        @participants << participant_id
      end
      
      #Removes this robot from the wavelet
      def remove_robot
        #TODO
      end
      
      #Sets the data document for the wavelet
      def set_data_document(name, data)
        #TODO
      end
      
      #Set the title
      def title=(title)
        @title = title
      end

      def root_blip
        @context.blips[@root_blip_id]
      end

      def wave
        @context.waves[@wave_id]
      end

      def print_structure(indent = 0) # :nodoc:
        text = @title.length > 24 ? "#{@title[0..20]}..." : @title
        str = ''
        str << "#{'  ' * indent}Wavelet:#{@id}:#{@participants.join(',')}:#{text}\n"
        
        if root_blip
          str << root_blip.print_structure(indent + 1)
        end

        str
      end
    end
  end
end
