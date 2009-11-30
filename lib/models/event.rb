#Represents and event
module Rave
  module Models
    class Event
      attr_reader :type, :timestamp, :modified_by, :properties
      
      #Event types:
      WAVELET_BLIP_CREATED = 'WAVELET_BLIP_CREATED'
      WAVELET_BLIP_REMOVED = 'WAVELET_BLIP_REMOVED'
      WAVELET_PARTICIPANTS_CHANGED = 'WAVELET_PARTICIPANTS_CHANGED'
      WAVELET_SELF_ADDED = 'WAVELET_SELF_ADDED'
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
      
      VALID_EVENTS = [
              WAVELET_BLIP_CREATED, WAVELET_BLIP_REMOVED, WAVELET_PARTICIPANTS_CHANGED,
              WAVELET_SELF_ADDED, WAVELET_TIMESTAMP_CHANGED, WAVELET_TITLE_CHANGED, WAVELET_VERSION_CHANGED,
              BLIP_CONTRIBUTORS_CHANGED, BLIP_DELETED, BLIP_SUBMITTED, BLIP_TIMESTAMP_CHANGED,
              BLIP_VERSION_CHANGED, DOCUMENT_CHANGED, FORM_BUTTON_CLICKED
           ]
      
      #Options include:
      # - :type
      # - :timestamp
      # - :modified_by
      # - :properties
      def initialize(options = {})
        @type = options[:type]
        @timestamp = options[:timestamp] || Time.now
        @modified_by = options[:modified_by]
        @properties = options[:properties] || {}
        
        # Allow properties to be directly accessed with Ruby-ised names.
        # event.participants_added <=> event.properties['participantsAdded']
        @properties.each_pair do |property, value|
          method_name = property.gsub(/([A-Z])/) { |s| "_#{$1.downcase}" }
          (class << self; self; end).class_eval do
            define_method method_name.to_sym do
              value
            end
          end
        end
      end
      
      #Returns true if the event_type is a possible event type, and false if not
      def self.valid_event_type?(event_type)
        VALID_EVENTS.include?(event_type)
      end
    end
  end
end