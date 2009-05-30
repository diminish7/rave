#Represents and event
module Rave
  module Models
    class Event
      attr_reader :type, :timestamp, :modified_by, :properties
      
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
      end
      
    end
  end
end