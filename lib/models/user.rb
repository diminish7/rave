module Rave
  module Models
    # A wave client, acting as a wave creator, blip contributor and/or a wavelet participant.
    class User < Component
      ROBOT_PATTERN = /@appspot\.com$/ # :nodoc:
      NOBODY_ID = "@@@NOBODY@@@" # :nodoc: Used as a default in certain circumstances.
      
      # Url link to the profile of the User.
      # NOTE: Due to a limitation in Wave, for all users except the local robot
      # the url will be empty.
      attr_reader :profile_url
      def profile_url # :nodoc:
        @profile_url.dup
      end

      # Url link to the image of the User.
      # NOTE: Due to a limitation in Wave, for all users except the local robot
      # the url will be empty.
      attr_reader :image_url
      def image_url # :nodoc:
        @image_url.dup
      end

      # - :id
      # - :name
      # - :profile_url
      # - :image_url
      # - :context
      def initialize(options = {}) # :nodoc:
        super(options)
        @name = options[:name]
        @profile_url = options[:profile_url] || ''
        @image_url = options[:image_url] || ''
      end

      # Printable name of the User.
      # NOTE: Due to a limitation in Wave, for all users except the local robot
      # the name is the same as the @id.
      attr_reader :name
      def name # :nodoc:
        @name || @id
      end

      # Is the User a robot client rather than a human client? [Boolean]
      attr_reader :robot?
      def robot? # :nodoc:
        not (@id =~ ROBOT_PATTERN).nil?
      end

      # Convert to string [String]
      def to_s
        @id
      end

      def to_json # :nodoc:
        @id.to_json
      end
    end
  end
end
