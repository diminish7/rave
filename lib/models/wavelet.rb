module Rave
  module Models
    # Represents a Wavelet, owned by a Wave
    class Wavelet < Component
      include Rave::Mixins::TimeUtils

      # Current version number of the wavelet [Integer]
      attr_reader :version

      # ID of the creator [String]
      def creator_id # :nodoc:
        @creator_id.dup
      end

      # Time the wavelet was created [Time]
      attr_reader :creation_time
      def creation_time # :nodoc:
        @creation_time.dup
      end

      # Documents contained within the wavelet [Array of Document]
      attr_reader :data_documents
      def data_documents # :nodoc:
        @data_documents.dup
      end

      # The last time the wavelet was modified [Time]
      attr_reader :last_modified_time
      def last_modified_time # :nodoc:
        @last_modified_time.dup
      end

      # ID for the root blip [String]
      def root_blip_id # :nodoc:
        @root_blip_id.dup
      end

      # Wavelet title [String]
      attr_accessor :title
      def title # :nodoc:
        @title.dup
      end

      # ID of the wave that the wavelet is a part of [String]
      def wave_id # :nodoc:
        @wave_id.dup
      end

      # IDs of all those who are currently members of the wavelet [Array of String]
      def participant_ids # :nodoc:
        @participant_ids.map { |id| id.dup }
      end

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
      def initialize(options = {}) # :nodoc:
        super(options)
        @creator_id = options[:creator] || User::NOBODY_ID
        @creation_time = time_from_json(options[:creation_time]) || Time.now
        @data_documents = options[:data_documents] || {}
        @last_modified_time = time_from_json(options[:last_modified_time]) || Time.now
        @participant_ids = options[:participants] || []
        @root_blip_id = options[:root_blip_id]
        @title = options[:title]
        @version = options[:version] || 0
        @wave_id = options[:wave_id]
      end

      # Users that are currently have access the wavelet [Array of User]
      attr_reader :participants
      def participants # :nodoc:
        @participant_ids.map { |p| @context.users[p] }
      end

      # Users that originally created the wavelet [User]
      attr_reader :creator
      def creator # :nodoc:
        @context.users[@creator_id]
      end
      
      #Creates a blip for this wavelet
      def create_blip
        parent = final_blip
        blip = Blip.new(:wave_id => @wave_id, :parent_blip_id => parent.id,
          :wavelet_id => @id, :context => @context, :creation => :generated)
        parent.add_child_blip(blip)
        
        @context.add_operation(:type => Operation::WAVELET_APPEND_BLIP, :wave_id => @wave_id, :wavelet_id => @id, :property => blip)
        blip
      end

      # Find the last blip in the main thread [Blip]
      def final_blip # :nodoc:
        blip = @context.blips[@root_blip_id]
        if blip
          while not blip.child_blips.empty?
            blip = blip.child_blips.first
          end
        end
        blip
      end
      
      #Adds a participant to the wavelet
      def add_participant(id) # :nodoc:
        if @context.users.has_key?(id)
          LOGGER.warning("Attempted to add a participant who was already in the wavelet(#{@id}): #{id}")
          return
        end

        # Allow string names to be used as participant.
        user = @context.add_user(:id => id)

        @context.add_operation(:type => Operation::WAVELET_ADD_PARTICIPANT,
          :wave_id => @wave_id, :wavelet_id => @id, :property => user)
        @participant_ids << id
      end
      
      #Removes this robot from the wavelet
      #
      # NOT IMPLEMENTED
      def remove_robot
        raise NotImplementedError
      end
      
      #Sets the data document for the wavelet
      #
      # NOT IMPLEMENTED
      def set_data_document(name, data)
        raise NotImplementedError
      end
      
      #Set the title
      #
      # NOT IMPLEMENTED
      def title=(title) # :nodoc: Documented by title() as accessor.
        raise NotImplementedError
        @title = title
      end

      # First blip in the wavelet [Blip]
      attr_reader :root_blip
      def root_blip # :nodoc:
        @context.blips[@root_blip_id]
      end

      # Wave that the wavelet is contained within.
      attr_reader :wave
      def wave# :nodoc:
        @context.waves[@wave_id]
      end

      # Convert to string.
      def to_s
        text = @title.length > 24 ? "#{@title[0..20]}..." : @title
        "#{super}:#{participants.join(',')}:#{text}"
      end

      def print_structure(indent = 0) # :nodoc:
        str = "#{'  ' * indent}#{to_s}\n"
        
        if root_blip
          str << root_blip.print_structure(indent + 1)
        end

        str
      end
    end
  end
end
