module Rave
  module Models
    # An element within a document.
    # (abstract factory)
    class Element < Component
      include Mixins::ObjectFactory

      JAVA_CLASS = "com.google.wave.api.FormElement"

      def initialize(properties = {})
        super(:id => '') # TODO: Don't actually have IDs, as such. Bad inheritance from Component?
        @properties = properties
      end

      # Gets the value of an element property.
      def get(key, default = nil)
        if @properties.has_key? key
          @properties[key]
        else
          default
        end
      end

      # Sets the value of an element property.
      def set(key, value)
        @properties[key] = value
      end

      # Alias for #set(key, value)
      alias_method :[]=, :set

      # Alias for #get(key)
      alias_method :[], :get

      def to_json # :nodoc:
        {
          'javaClass' => JAVA_CLASS,
          'properties' => @properties,
          'type' => type,
        }.to_json
      end

      # A Google Gadget element within a document.
      class Gadget < Element
        TYPE = 'GADGET'

        factory_register

        def initialize(fields = {})
          # Gadget has 'fields' rather than 'properties'.
          super(fields)
        end
      end

      # An image element within a document.
      class Image < Element
        TYPE = 'IMAGE'

        factory_register
      end

      # An inline blip within a document.
      class InlineBlip < Element
        TYPE = 'INLINE_BLIP'

        factory_register

        # The blip contained within the element [Blip].
        attr_reader :blip
        def blip # :nodoc:
          @context.blips[@properties['blipId']]
        end
      end

      # A form element within a document.
      # (Abstract)
      class FormElement < Element
      end

      # A button form element within a document.
      class Button < FormElement
        TYPE = 'BUTTON'

        factory_register
      end

      # A check form element within a document.
      class Check < FormElement
        TYPE = 'CHECK'

        factory_register
      end

      # A input form element within a document.
      class Input < FormElement
        TYPE = 'INPUT'

        factory_register
      end

      # A password form element within a document.
      class Password < FormElement
        TYPE = 'PASSWORD'

        factory_register
      end

      # A label form element within a document.
      class Label < FormElement
        TYPE = 'LABEL'

        factory_register
      end

      # A radio button form element within a document.
      class RadioButton < FormElement
        TYPE = 'RADIO_BUTTON'

        factory_register
      end

      # A radio button group form element within a document.
      class RadioButtonGroup < FormElement
        TYPE = 'RADIO_BUTTON_GROUP'

        factory_register
      end

      # A text-area form element within a document.
      class TextArea < FormElement
        TYPE = 'TEXTAREA'

        factory_register
      end
    end
  end
end
