module Rave
  module Models
    # Represents a Wavelet, owned by a Wave
    class Wavelet < Component
      include Rave::Mixins::TimeUtils
      include Rave::Mixins::Logger

      # Creator of the wavelet if it was generated via an operation.
      GENERATED_CREATOR = "rusty@a.gwave.com" # :nodoc:

      # Current version number of the wavelet [Integer]
      attr_reader :version

      # ID of the creator [String]
      def creator_id # :nodoc:
        @creator_id.dup
      end

      # Time the wavelet was created [Time]
      def creation_time # :nodoc:
        @creation_time.dup
      end

      # Documents contained within the wavelet [Array of Document]
      def data_documents # :nodoc:
        @data_documents.dup
      end

      # The last time the wavelet was modified [Time]
      def last_modified_time # :nodoc:
        @last_modified_time.dup
      end

      # ID for the root blip [String]
      def root_blip_id # :nodoc:
        @root_blip_id.dup
      end

      # Wavelet title [String]
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

      JAVA_CLASS = 'com.google.wave.api.impl.WaveletData'
      ROOT_ID_SUFFIX = "conv+root"   #The suffix for the root wavelet in a wave]
      ROOT_ID_REGEXP = /#{Regexp.escape(ROOT_ID_SUFFIX)}$/

      #
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
        @participant_ids = options[:participants] || []

        if options[:id].nil? and options[:context]
          # Generate the wavelet from scratch.
          super(:id => "#{GENERATED_PREFIX}_wavelet_#{unique_id}_#{ROOT_ID_SUFFIX}", :context => options[:context])

          # Create a wave to live in.
          wave = Wave.new(:wavelet_ids => [@id], :context => @context)
          @wave_id = wave.id
          @context.add_wave(wave)
          
          # Ensure the newly created wavelet has a root blip.
          blip = Blip.new(:wave_id => wave.id, :wavelet_id => @id,
            :creator => @context.robot.id, :contributors => [@context.robot.id])
          @context.add_blip(blip)
          @root_blip_id = blip.id

          @participant_ids.each do |id|
            @context.add_user(:id => id) unless @context.users[id]
          end

          @creator_id = GENERATED_CREATOR
          @context.add_user(:id => @creator_id) unless @context.users[@creator_id]
        else
          super(options)
          @root_blip_id = options[:root_blip_id]
          @creator_id = options[:creator] || User::NOBODY_ID
          @wave_id = options[:wave_id]
        end

        @creation_time = time_from_json(options[:creation_time]) || Time.now
        @data_documents = options[:data_documents] || {}
        @last_modified_time = time_from_json(options[:last_modified_time]) || Time.now
        @title = options[:title] || ''
        @version = options[:version] || 0
      end

      # Users that are currently have access the wavelet [Array of User]
      def participants # :nodoc:
        @participant_ids.map { |p| @context.users[p] }
      end

      # Users that originally created the wavelet [User]
      def creator # :nodoc:
        @context.users[@creator_id]
      end

      # Is this the root wavelet for its wave? [Boolean]
      def root? # :nodoc:
        not (id =~ ROOT_ID_REGEXP).nil?
      end
      
      #Creates a blip for this wavelet
      # Returns: Gererated blip [Blip]
      def create_blip
        parent = final_blip
        blip = Blip.new(:wave_id => @wave_id, :parent_blip_id => parent.id,
          :wavelet_id => @id, :context => @context)
        parent.add_child_blip(blip)
        
        @context.add_operation(:type => Operation::WAVELET_APPEND_BLIP, :wave_id => @wave_id, :wavelet_id => @id, :property => blip)
        blip
      end

      # Find the last blip in the main thread [Blip]
      def final_blip # :nodoc:
        blip = @context.blips[@root_blip_id]
        if blip
          while blip
            # Find the first blip that is defined, if at all.
            child_blip = blip.child_blips.find { |b| not b.nil? }
            break unless child_blip
            blip = child_blip
          end
        end
        blip
      end
      
      # Adds a participant (human or robot) to the wavelet
      # +user+:: User to add, as ID or object [String or User]
      # Returns: The user that was added [User or nil]
      def add_participant(user) # :nodoc:
        id = user.to_s.downcase
        if @participant_ids.include?(id)
          logger.warning("Attempted to add a participant who was already in the wavelet(#{@id}): #{id}")
          return nil
        end

        # Allow string names to be used as participant.
        user = if @context.users[id]
          @context.users[id]
        else
          @context.add_user(:id => id)
        end

        @context.add_operation(:type => Operation::WAVELET_ADD_PARTICIPANT,
          :wave_id => @wave_id, :wavelet_id => @id, :property => user)
        @participant_ids << id
        
        user
      end

      # Removes a participant (robot only) from the wavelet.
      # +user+:: User to remove, as ID or object [String or User]
      # Returns: The user that was removed [User or nil]
      def remove_participant(user) # :nodoc:
        id = user.to_s.downcase
        unless @participant_ids.include?(id)
          logger.warning("Attempted to remove a participant who was not in the wavelet(#{@id}): #{id}")
          return nil
        end

        # Allow string names to be used as participant.
        user = @context.users[id]

        unless user.robot?
          logger.warning("Attempted to remove a non-robot from wavelet(#{@id}): #{id}")
          return nil
        end

        if user == @context.robot
          return remove_robot
        end

        @context.add_operation(:type => Operation::WAVELET_REMOVE_PARTICIPANT,
          :wave_id => @wave_id, :wavelet_id => @id, :property => user)
        @participant_ids.delete id
        
        user
      end
      
      # Removes the local robot from the wavelet.
      # Returns: The local robot [Robot]
      def remove_robot
        robot = @context.robot
        @context.add_operation(:type => Operation::WAVELET_REMOVE_SELF,
          :wave_id => @wave_id, :wavelet_id => @id)
        @participant_ids.delete robot.id

        robot
      end
      
      #Sets the data document for the wavelet
      #
      # NOT IMPLEMENTED
      def set_data_document(name, data)
        raise NotImplementedError
      end
      
      #Set the title
      #
      def title=(title) # :nodoc: Documented by title() as accessor.
        title = title.to_s
        @context.add_operation(:type => Operation::WAVELET_SET_TITLE,
          :wave_id => @wave_id, :wavelet_id => @id, :property => title)
        # Update the first line of the root blip
        if (blip = self.root_blip)
          blip.send(:set_title_text, title)
        end
        @title = title
      end
      
      # First blip in the wavelet [Blip]
      def root_blip # :nodoc:
        @context.blips[@root_blip_id]
      end

      # Wave that the wavelet is contained within.
      def wave# :nodoc:
        @context.waves[@wave_id]
      end

      # *INTERNAL*
      # Convert to json for sending in an operation.
      def to_json # :nodoc:
        {
          'waveletId' => @id,
          'javaClass' => JAVA_CLASS,
          'waveId' => @wave_id,
          'rootBlipId' => @root_blip_id,
          'participants' => { "javaClass" => "java.util.ArrayList", "list" => @participant_ids }
        }.to_json
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
      
    protected
      # * INTERNAL *
      # Set the title locally - used when the first line of the root blip is updated
      def set_title_locally(title)
        @title = title
      end
      
    end
  end
end
