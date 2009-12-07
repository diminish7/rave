# A wave client, acting as a wave creator, blip contributor and/or a wavelet participant.
module Rave
  module Models
    class User < Component
      ROBOT_PATTERN = /@appspot\.com$/ # :nodoc:
      NOBODY_ID = "@@@NOBODY@@@" # :nodoc: Used as a default in certain circumstances.
      
      # Url link to the profile of the User.
      # NOTE: Due to a limitation in Wave, for all users except the local robot
      #       the url will be empty.
      attr_reader :profile_url

      # Url link to the image of the User.
      # NOTE: Due to a limitation in Wave, for all users except the local robot
      #       the url will be empty.
      attr_reader :image_url
      # - :id
      # - :name
      # - :profile_url
      # - :image_url
      # - :context
      def initialize(options = {})
        super(options)
        @name = options[:name]
        @profile_url = options[:profile_url] || ''
        @image_url = options[:image_url] || ''
      end

      # Printable name of the User.
      # NOTE: Due to a limitation in Wave, for all users except the local robot
      #       the name is the same as the @id.
      def name; @name || @id; end

      # Is the User a robot client rather than a human client?
      def robot?; not (@id =~ ROBOT_PATTERN).nil?; end

      def to_s
        @id
      end

      def to_json
        @id.to_json
      end
    end
  end
end
