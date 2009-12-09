#Represents and event
module Rave
  module Models
    class Event
      include Rave::Mixins::TimeUtils

      BLIP_ID = 'blipId' # :nodoc:
      
      def timestamp; @timestamp.dup; end
      def modified_by_id; @modified_by_id.dup; end
      def blip_id; @properties[BLIP_ID].dup; end
      
      #Event types:
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

      # The User that caused this event to be generated.
      def modified_by
        @context.users[@modified_by_id]
      end
      
      # Event factory.
      # - :type
      # - :timestamp
      # - :modified_by
      # - :properties
      def self.create(options = {})
        event_class = EVENT_CLASSES.find { |e| e.type == options[:type] }      
        raise ArgumentError.new("Unknown event type #{options[:type]}") if event_class.nil?
        
        event_class.new(options)
      end
      
      # Type of particular event, as defined in the Wave protocol.
      def self.type
        raise "#{self.class} is abstract and should not be instanced."
      end

      def self.valid_event_type?(type)
        not EVENT_CLASSES.find { |e| e.type == type }.nil?
      end
      
      # Blip affected, or wavelet's root blip for wavelet events.
      def blip
        @context.blips[@properties[BLIP_ID]]
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
        def self.type; WAVELET_BLIP_CREATED.dup; end
        
        # Newly created blip.
        def new_blip
          @context.blips[@properties['newBlipId']]
        end
      end
      
      class WaveletBlipRemovedEvent < Event
        def self.type; WAVELET_BLIP_REMOVED.dup; end
        
        # ID for blip which has now been removed.
        def removed_blip_id
          @properties['removedBlipId'].dup
        end
      end
      
      class WaveletParticipantsChangedEvent < Event
        def self.type; WAVELET_PARTICIPANTS_CHANGED.dup; end

        ADDED = 'participantsAdded' # :nodoc:
        REMOVED = 'participantsRemoved' # :nodoc:

        def initialize(options)
          super(options)
          
          add_user_ids(@properties[ADDED]) if @properties[ADDED]
          add_user_ids(@properties[REMOVED]) if @properties[REMOVED]
        end
        
        # Array of participants added to the wavelet.
        def participants_added
          @properties[ADDED].map { |id| @context.users[id] }
        end
        
        # Array of participants added to the wavelet.
        def participants_removed
          @properties[REMOVED].map { |id| @context.users[id] }
        end
      end
      
      class WaveletSelfAddedEvent < Event
        def self.type; WAVELET_SELF_ADDED.dup; end
      end
      
      class WaveletSelfRemovedEvent < Event
        def self.type; WAVELET_SELF_REMOVED.dup; end
      end
      
      class WaveletTimestampChangedEvent < Event
        def self.type; WAVELET_TIMESTAMP_CHANGED.dup; end
        
        def timestamp
          @properties['timestamp'].dup
        end
      end
      
      class WaveletTitleChangedEvent < Event
        def self.type; WAVELET_TITLE_CHANGED.dup; end
        
        def title
          @properties['title'].dup
        end
      end
            
      class WaveletVersionChangedEvent < Event
        def self.type; WAVELET_VERSION_CHANGED.dup; end
        
        def version
          @properties['version'].dup
        end
      end
      
      # Blip events
      
      class BlipContributorsChangedEvent < Event
        def self.type; BLIP_CONTRIBUTORS_CHANGED.dup; end

        ADDED = 'contributorsAdded' # :nodoc:
        REMOVED = 'contributorsRemoved' # :nodoc:

        def initialize(options)
          super(options)

          add_user_ids(@properties[ADDED]) if @properties[ADDED]
          add_user_ids(@properties[REMOVED]) if @properties[REMOVED]
        end

        # Array of contributors added to the wavelet.
        def contributors_added
          @properties[ADDED].map { |id| @context.users[id] }
        end
        
        # Array of contributors added to the wavelet.
        def contributors_removed
          @properties[REMOVED].map { |id| @context.users[id] }
        end
      end
      
      class BlipSubmittedEvent < Event
        def self.type; BLIP_SUBMITTED.dup; end
      end

      # #blip will have been created virtual+deleted if it was still referenced
      # in the json. If not, it was destroyed and all you have is the #blip_id.
      class BlipDeletedEvent < Event
        def self.type; BLIP_DELETED.dup; end

        def initialize(options = {})
          super(options)

          # Ensure a referenced blip is properly deleted. Destroyed blip won't exist.
          blip.delete_me(false) if @properties[BLIP_ID] and blip
        end
      end
      
      # General events.
      
      class DocumentChangedEvent < Event
        def self.type; DOCUMENT_CHANGED.dup; end
      end
      
      class FormButtonClickedEvent < Event
        def self.type; FORM_BUTTON_CLICKED.dup; end
        
        # Name of button that was clicked.
        def button
          @properties['button'].dup
        end
      end
      
      EVENT_POSTFIX = 'Event' # :nodoc:
      # List of all the event classes (other than Event, which is abstract).
      EVENT_CLASSES = self.constants.inject([]) do |classes, constant|
        if constant[-(EVENT_POSTFIX.length)..-1] == EVENT_POSTFIX and constant != Event.name
          classes.push eval constant
        else
          classes
        end
      end
    end
  end
end
