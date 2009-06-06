# Represents a Wavelet, owned by a Wave
module Rave
  module Models
    class Wavelet
      attr_reader :creator, :creation_time, :data_documents, :last_modified_time, 
                  :participants, :root_blip_id, :title, :version, :wave_id, :id
      attr_accessor :context  #Context needs to be able to set this
      
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
        @creator = options[:creator]
        @creation_time = options[:creation_time] || Time.now
        @data_documents = options[:data_documents] || {}
        @last_modified_time = options[:last_modified_time] || Time.now
        @participants = Set.new(options[:participants])
        @root_blip_id = options[:root_blip_id]
        @title = options[:title]
        @version = options[:version] || 0
        @wave_id = options[:wave_id]
        @context = options[:context]
        @id = options[:id]
      end
      
      #Creates a blip for this wavelet
      def create_blip
        #TODO
        blip = Blip.new(:wave_id => @wave_id, :wavelet_id => @id)
        @context.operations << Operation.new(:type => Operation::WAVELET_APPEND_BLIP, :wave_id => @wave_id, :wavelet_id => @id, :prop => blip)
        @context.add_blip(blip)
        blip
      end
      
      #Adds a participant to the wavelet
      def add_participant(participant_id)
        #TODO
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
      
    end
  end
end