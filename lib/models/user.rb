# A wave client, acting as a wave creator, blip contributor and/or a wavelet participant.
module Rave
  module Models
    class User < Component
      ROBOT_PATTERN = /@appspot.com$/ # :nodoc:
      
      # Url link of the User.
      # NOTE: Due to a limitation in Wave, for all users except the local robot
      #       the url will be empty.
      attr_reader :url

      # - :id
      # - :name
      # - :url
      # - :context
      def initialize(options = {})
        super(options)
        @name = options[:name]
        @url = options[:url] || ''
      end

      # Printable name of the User.
      # NOTE: Due to a limitation in Wave, for all users except the local robot
      #       the name is the same as the @id.
      def name; @name || @id; end

      # Is the User a robot client rather than a human client?
      def robot?; not (@id =~ ROBOT_PATTERN).nil?; end
    end
  end
end