#Represents and event
module Rave
  module Models
    class Event
      attr_reader :timestamp, :modified_by, :properties
      
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
      # Do not use Event.new from outside; instead use Event.create
      def initialize(options = {})
        @timestamp = options[:timestamp] || Time.now
        @modified_by = options[:modified_by]
        @properties = options[:properties] || {}
      end
      
      # Event factory.
      # - :type
      # - :timestamp
      # - :modified_by
      # - :properties
      def self.create(options = {})
        event_class = EVENT_CLASSES.find { |e| e.type == options[:type] }
        
        raise "Unknown event type #{options[:type]}" if event_class.nil?
        
        options[:type] = nil
        event_class.new(options)
      end
      
      # Type of particular event, as defined in the Wave protocol.
      def self.type
        raise "#{self.class} is abstract and should not be instanced."
      end

      def self.valid_event_type?(type)
        not EVENT_CLASSES.find { |e| e.type == type }.nil?
      end
      
    public 
      # Blip affected, or wavelet's root blip for wavelet events.
      def blip
        @context.blips[@properties['blipId']]
      end
      
      # Type of particular event, as defined in the Wave protocol.
      def type
        self.class.type
      end
      
      # Wavelet events
      
      class WaveletBlipCreatedEvent < Event
      public
        def self.type; WAVELET_BLIP_CREATED; end
        
        # Newly created blip.
        def new_blip
          @context.blips[@properties['newBlipId']]
        end
      end
      
      class WaveletBlipRemovedEvent < Event
        def self.type; WAVELET_BLIP_REMOVED; end
        
        # ID for blip which has now been removed.
        def removed_blip_id
          @properties['removedBlipId']
        end
      end
      
      class WaveletParticipantsChangedEvent < Event
        def self.type; WAVELET_PARTICIPANTS_CHANGED; end
        
        # Array of participants added to the wavelet.
        def participants_added
          @properties['participantsAdded']
        end
        
        # Array of participants added to the wavelet.
        def participants_removed
          @properties['participantsRemoved']
        end
      end
      
      class WaveletSelfAddedEvent < Event
        def self.type; WAVELET_SELF_ADDED; end
      end
      
      class WaveletSelfRemovedEvent < Event
        def self.type; WAVELET_SELF_REMOVED; end
      end
      
      class WaveletTimestampChangedEvent < Event
        def self.type; WAVELET_TIMESTAMP_CHANGED; end
        
        def timestamp
          @properties['timestamp']
        end
      end
      
      class WaveletTitleChangedEvent < Event
        def self.type; WAVELET_TITLE_CHANGED; end
        
        def title
          @properties['title']
        end
      end
            
      class WaveletVersionChangedEvent < Event
        def self.type; WAVELET_VERSION_CHANGED; end
        
        def version
          @properties['version']
        end
      end
      
      # Blip events
      
      class BlipContributorsChangedEvent < Event
        def self.type; BLIP_CONTRIBUTORS_CHANGED; end
        
        # Array of contributors added to the wavelet.
        def contributors_added
          @properties['contributorsAdded']
        end
        
        # Array of contributors added to the wavelet.
        def contributors_removed
          @properties['contributorsRemoved']
        end
      end
      
      class BlipSubmittedEvent < Event
        def self.type; BLIP_SUBMITTED; end
      end
      
      class BlipDeletedEvent < Event
        def self.type; BLIP_DELETED; end
      end
      
      # General events.
      
      class DocumentChangedEvent < Event
        def self.type; DOCUMENT_CHANGED; end
      end
      
      class FormButtonClickedEvent < Event
        def self.type; FORM_BUTTON_CLICKED; end
        
        # Name of button that was clicked.
        def button
          @properties['button']
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
