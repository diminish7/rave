module Rave
  module Models
    # A wave client, acting as a wave creator, blip contributor and/or a wavelet participant.
    class User < Component
      ROBOT_PATTERN = /@appspot\.com$/ # :nodoc:
      NOBODY_ID = "@@@nobody@@@" # :nodoc: Used as a default in certain circumstances.

      # Url link to the profile of the User [String].
      # NOTE: Due to a limitation in Wave, for all users except the local robot
      # the url will be empty.
      def profile_url # :nodoc:
        @profile_url.dup
      end

      # Url link to the image of the User [String].
      # NOTE: Due to a limitation in Wave, for all users except the local robot
      # the url will be empty.
      def image_url # :nodoc:
        @image_url.dup
      end

      # Unlike other components, Users are never generated [Boolean].
      def generated? # :nodoc:
        false
      end

      # - :id
      # - :name
      # - :profile_url
      # - :image_url
      # - :context
      def initialize(options = {}) # :nodoc:
        options[:id].downcase! if options[:id]
        super(options)
        @name = options[:name]
        @profile_url = options[:profile_url] || ''
        @image_url = options[:image_url] || ''
      end

      # Printable name of the User [String].
      # NOTE: Due to a limitation in Wave, for all users except the local robot
      # the name is the same as the @id.
      def name # :nodoc:
        @name || @id
      end

      # Is the User a robot client rather than a human client? [Boolean]
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
