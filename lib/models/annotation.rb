module Rave
  module Models
    # An annotation applying styling or other meta-data to a section of text.
    class Annotation
      include Rave::Mixins::ObjectFactory

      JAVA_CLASS = "com.google.wave.api.Annotation"

      # Name of the annotation type [String]
      def name # :nodoc:
        # If @id is defined, then put that into the type, otherwise just the type is fine.
        @id ? type.sub(WILDCARD, @id) : type
      end

      # Value of the annotation [String]
      def value # :nodoc:
        @value.dup
      end

      # Range of characters over which the annotation applies [Range]
      def range # :nodoc:
        @range.dup
      end

      # +value+:: Value of the annotation [String]
      # +range+:: Range of characters that the annotation applies to [Range]
      def initialize(value, range); end
      # +id+:: The non-class-dependent part of the name [String]
      # +value+:: Value of the annotation [String]
      # +range+:: Range of characters that the annotation applies to [Range]
      def initialize(id, value, range); end
      def initialize(*args) # :nodoc:
        case args.length
        when 3
          @id, @value, @range = args
        when 2
          @value, @range = args
        end
      end

      def to_json # :nodoc:
        {
          'javaClass' => JAVA_CLASS,
          'name' => name,
          'value' => value,
          'range' => range.to_rave_hash,
        }.to_json
      end

      factory_register '*' # Accept all unrecognised annotations.

      # Annotation classes:

      # Language selected, such as "en", "de", etc.
      class Language < Annotation
        factory_register 'lang'
      end

      # Style, acting the same as the similarly named CSS properties.
      class Style < Annotation

        factory_register 'style/*' # Accept all unrecognised style annotations.

        class BackgroundColor < Style
          factory_register 'style/backgroundColor'
        end

        class Color < Style
          factory_register 'style/color'
        end

        class FontFamily < Style
          factory_register 'style/fontFamily'
        end

        class FontSize < Style
          factory_register 'style/fontSize'
        end

        class FontWeight < Style
          factory_register 'style/fontWeight'
        end

        class TextDecoration < Style
          factory_register 'style/textDecoration'
        end

        class VerticalAlign < Style
          factory_register 'style/verticalAlign'
        end
      end

      class Conversation < Annotation
        factory_register 'conv/*' # Accept all unrecognised conv annotations.

        class Title < Conversation
          factory_register "conv/title"
        end
      end

      # (Abstract)
      class Link < Annotation
        factory_register 'link/*' # Accept all unrecognised link annotations.

        class Manual < Link
          factory_register "link/manual"
        end

        class Auto < Link
          factory_register "link/autoA"
        end

        class Wave < Link
          factory_register "link/waveA"
        end
      end

      # (Abstract)
      class User < Annotation
        factory_register 'user/*' # Accept all unrecognised user annotations.

        # Session ID for the user annotation.
        def session_id # :nodoc:
          name =~ %r!/([^/]+)$!
          $1
        end

        def initialize(session_id, value, range)
          super
        end

        class Document < User
          factory_register "user/d/*"
        end

        class Selection < User
          factory_register "user/r/*"
        end

        class Focus < User
          factory_register "user/e/*"
        end
      end
    end
  end
end
