module Rave
  module Models
    # Represents an event received from the server.
    class Event
      include Rave::Mixins::TimeUtils

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

      # Type of particular event, as defined in the Wave protocol [String]
      attr_reader :type
      def type # :nodoc:
        self.class.type
      end
      
      # Event type names, as sent over the wave json protocol.
      module Types
        WAVELET_BLIP_CREATED = 'WAVELET_BLIP_CREATED'
        WAVELET_BLIP_REMOVED = 'WAVELET_BLIP_REMOVED'
        WAVELET_PARTICIPANTS_CHANGED = 'WAVELET_PARTICIPANTS_CHANGED'
        WAVELET_SELF_ADDED = 'WAVELET_SELF_ADDED'
        WAVELET_SELF_REMOVED = 'WAVELET_SELF_REMOVED'
        WAVELET_TIMESTAMP_CHANGED = 'WAVELET_TIMESTAMP_CHANGED'
        WAVELET_TITLE_CHANGED = 'WAVELET_TITLE_CHANGED'
        WAVELET_VERSION_CHANGED = 'WAVELET_VERSION_CHANGED'
        BLIP_CONTRIBUTORS_CHANGED = 'BLIP_CONTRIBUTORS_CHANGED'
        BLIP_DELETED = 'BLIP_DELETED'
        BLIP_SUBMITTED = 'BLIP_SUBMITTED'
        BLIP_TIMESTAMP_CHANGED = 'BLIP_TIMESTAMP_CHANGED'
        BLIP_VERSION_CHANGED = 'BLIP_VERSION_CHANGED'
        DOCUMENT_CHANGED = 'DOCUMENT_CHANGED'
        FORM_BUTTON_CLICKED = 'FORM_BUTTON_CLICKED'
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
      
      # Event factory.
      # - :type
      # - :timestamp
      # - :modified_by
      # - :properties
      def self.create(options = {}) # :nodoc:
        event_class = sub_classes.find { |e| e.type == options[:type] }
        raise ArgumentError.new("Unknown event type #{options[:type]}") if event_class.nil?
        
        event_class.new(options)
      end
      
      # Type of particular event, as defined in the Wave protocol [String]
      def self.type
        raise "#{self.class} is abstract and should not be instanced."
      end

      # Is this event type able to be handled?
      def self.valid_event_type?(type) # :nodoc:
        not sub_classes.find { |e| e.type == type }.nil?
      end

      # List of all the event classes (other than Event itself) [Array of Event].
      def self.sub_classes # :nodoc:
        @@sub_classes ||= constants.map { |c| eval c }.select { |v| v.kind_of? Class }
      end

      # Type of particular event, as defined in the Wave protocol.
      def type
        self.class.type
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
      class WaveletBlipCreatedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::WAVELET_BLIP_CREATED.dup; end
        
        # Newly created blip [Blip]
        attr_reader :new_blip
        def new_blip # :nodoc:
          @context.blips[@properties['newBlipId']]
        end
      end
      
      class WaveletBlipRemovedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::WAVELET_BLIP_REMOVED.dup; end
        
        # ID for blip which has now been removed [String]
        attr_reader :removed_blip_id
        def removed_blip_id # :nodoc:
          @properties['removedBlipId'].dup
        end
      end
      
      class WaveletParticipantsChangedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::WAVELET_PARTICIPANTS_CHANGED.dup; end

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
      
      class WaveletSelfAddedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::WAVELET_SELF_ADDED.dup; end
      end
      
      class WaveletSelfRemovedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::WAVELET_SELF_REMOVED.dup; end
      end
      
      class WaveletTimestampChangedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::WAVELET_TIMESTAMP_CHANGED.dup; end

        # Time that the wavelet was changed [Time]
        attr_reader :new_timestamp
        def new_timestamp # :nodoc:
          @properties['timestamp'].dup
        end
      end
      
      class WaveletTitleChangedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::WAVELET_TITLE_CHANGED.dup; end

        attr_reader :new_title
        def new_title # :nodoc:
          @properties['title'].dup
        end
      end
            
      class WaveletVersionChangedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::WAVELET_VERSION_CHANGED.dup; end

        attr_reader :new_version
        def new_version # :nodoc:
          @properties['version'].dup
        end
      end
      
      # Blip events
      
      class BlipContributorsChangedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::BLIP_CONTRIBUTORS_CHANGED.dup; end

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
      
      class BlipSubmittedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::BLIP_SUBMITTED.dup; end
      end

      # #blip will have been created virtual+deleted if it was still referenced
      # in the json. If not, it was destroyed and all you have is the #blip_id.
      class BlipDeletedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::BLIP_DELETED.dup; end

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
      
      class DocumentChangedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::DOCUMENT_CHANGED.dup; end
      end
      
      class FormButtonClickedEvent < Event
        # Type of particular event, as defined in the Wave protocol [String]
        def self.type; Types::FORM_BUTTON_CLICKED.dup; end
        
        # Name of button that was clicked.
        attr_reader :button
        def button # :nodoc:
          @properties['button'].dup
        end
      end
    end
  end
end
