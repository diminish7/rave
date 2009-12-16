module Rave
  module Models
    # Represents an event received from the server.
    class Event
      include Rave::Mixins::TimeUtils
      include Rave::Mixins::ObjectFactory

      BLIP_ID = 'blipId' # :nodoc:
      
      # Time at which the event was created [Time]
      attr_reader :timestamp
      def timestamp # :nodoc:
        @timestamp.dup
      end

      # ID of the blip that caused the event, or root blip of the wavelet that caused the event [String]
      def blip_id # :nodoc:
        @properties[BLIP_ID].dup
      end

      # Wavelet that caused the event, or wavelet containing the blip that caused the event [Wavelet]
      attr_reader :wavelet
      def wavelet # :nodoc:
        @context.primary_wavelet
      end

      # The user that caused this event to be generated [User]
      attr_reader :modified_by
      def modified_by # :nodoc:
        @context.users[@modified_by_id]
      end

      # Blip that caused the event, or wavelet's root blip for wavelet events [Blip]
      attr_reader :blip
      def blip # :nodoc:
        @context.blips[@properties[BLIP_ID]]
      end

      #Options include:
      # - :timestamp
      # - :modified_by
      # - :properties
      # - :context
      # Do not use Event.new from outside; instead use Event.create
      def initialize(options = {}) # :nodoc:
        @timestamp = time_from_json(options[:timestamp]) || Time.now
        @modified_by_id = options[:modified_by] || User::NOBODY_ID
        @properties = options[:properties] || {}
        @context = options[:context]

        raise ArgumentError.new(":context option required") if @context.nil?

        add_user_ids([@modified_by_id])
      end

    protected
      # Add a series of user ids to the context, if they don't already exist.
      def add_user_ids(user_ids) # :nodoc:
        user_ids.each do |id|
          @context.add_user(:id => id) unless @context.users[id]
        end
      end
      
      # Wavelet events

    public
      class WaveletBlipCreated < Event
        factory_register 'WAVELET_BLIP_CREATED'
        
        # Newly created blip [Blip]
        attr_reader :new_blip
        def new_blip # :nodoc:
          @context.blips[@properties['newBlipId']]
        end
      end
      
      class WaveletBlipRemoved < Event
        factory_register 'WAVELET_BLIP_REMOVED'
        
        # ID for blip which has now been removed [String]
        attr_reader :removed_blip_id
        def removed_blip_id # :nodoc:
          @properties['removedBlipId'].dup
        end
      end
      
      class WaveletParticipantsChanged < Event
        factory_register 'WAVELET_PARTICIPANTS_CHANGED'

        ADDED = 'participantsAdded' # :nodoc:
        REMOVED = 'participantsRemoved' # :nodoc:

        def initialize(options = {}) # :nodoc:
          super(options)
          
          add_user_ids(@properties[ADDED]) if @properties[ADDED]
          add_user_ids(@properties[REMOVED]) if @properties[REMOVED]
        end
        
        # Array of participants added to the wavelet [Array of User]
        attr_reader :participants_added
        def participants_added # :nodoc:
          @properties[ADDED].map { |id| @context.users[id] }
        end
        
        # Array of participants removed from the wavelet [Array of User].
        attr_reader :participants_removed
        def participants_removed # :nodoc:
          @properties[REMOVED].map { |id| @context.users[id] }
        end
      end
      
      class WaveletSelfAdded < Event
        factory_register 'WAVELET_SELF_ADDED'
      end
      
      class WaveletSelfRemoved < Event
        factory_register 'WAVELET_SELF_REMOVED'
      end
      
      class WaveletTimestampChanged < Event
        factory_register 'WAVELET_TIMESTAMP_CHANGED'

        # Time that the wavelet was changed [Time]
        attr_reader :new_timestamp
        def new_timestamp # :nodoc:
          @properties['timestamp'].dup
        end
      end
      
      class WaveletTitleChanged < Event
        factory_register 'WAVELET_TITLE_CHANGED'

        attr_reader :new_title
        def new_title # :nodoc:
          @properties['title'].dup
        end
      end
            
      class WaveletVersionChanged < Event
        factory_register 'WAVELET_VERSION_CHANGED'

        attr_reader :new_version
        def new_version # :nodoc:
          @properties['version'].dup
        end
      end
      
      # Blip events
      
      class BlipContributorsChanged < Event
        factory_register 'BLIP_CONTRIBUTORS_CHANGED'

        ADDED = 'contributorsAdded' # :nodoc:
        REMOVED = 'contributorsRemoved' # :nodoc:

        def initialize(options = {}) # :nodoc:
          super(options)

          add_user_ids(@properties[ADDED]) if @properties[ADDED]
          add_user_ids(@properties[REMOVED]) if @properties[REMOVED]
        end

        # Array of contributors added to the wavelet [Array of User].
        attr_reader :contributors_added
        def contributors_added # :nodoc:
          @properties[ADDED].map { |id| @context.users[id] }
        end
        
        # Array of contributors removed from the wavelet [Array of User].
        attr_reader :contributors_removed
        def contributors_removed # :nodoc:
          @properties[REMOVED].map { |id| @context.users[id] }
        end
      end
      
      class BlipSubmitted < Event
        factory_register 'BLIP_SUBMITTED'
      end

      # #blip will be nil, but #blip_id will give a sensible value.
      class BlipDeleted < Event
        factory_register 'BLIP_DELETED'

        # ID of the blip that was deleted [String]
        #-- This dummy method just added for the purposes of rdoc.
        attr_reader :blip_id
        def blip_id # :nodoc:
          super
        end

        def initialize(options = {}) # :nodoc:
          super(options)

          # Ensure a referenced blip is properly deleted. Destroyed blip won't exist.
          blip.delete_me(false) if @properties[BLIP_ID] and blip
        end
      end
      
      # General events.
      
      class DocumentChanged < Event
        factory_register 'DOCUMENT_CHANGED'
      end
      
      class FormButtonClicked < Event
        factory_register 'FORM_BUTTON_CLICKED'
        
        # Name of button that was clicked.
        attr_reader :button
        def button # :nodoc:
          @properties['button'].dup
        end
      end

      # Generated when someone in the current wave creates a new wavelet (in a new wave).
      class WaveletCreated < Event
        factory_register 'WAVELET_CREATED'
      end

      class OperationError < Event
        factory_register 'OPERATION_ERROR'

        # Message describing what caused the error [String]
        attr_reader :message
        def message # :nodoc:
          @properties['errorMessage'].dup
        end

        # Operation type that caused the error [String]
        attr_reader :operation_type
        def operation_type # :nodoc:
          # Format is "document.appendMarkup1260632282946" (number is timestamp)
          @properties['operationId'] =~ /^(.+?)\d+$/
          "#{$1.split(/(?=[A-Z])|\./).join('_').upcase}"
        end

        # Time of the err [String]
        attr_reader :operation_timestamp
        def operation_timestamp # :nodoc:
          # Format is "document.appendMarkup1260632282946" (number is timestamp)
          @properties['operationId'] =~ /(\d+)$/
          time_from_json($1)
        end
      end
    end
  end
end
