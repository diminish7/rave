module Rave
  module Models
    # An element within a document.
    # (abstract factory)
    class Element < Component
      include Rave::Mixins::ObjectFactory

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
        factory_register 'GADGET'

        def initialize(fields = {})
          # Gadget has 'fields' rather than 'properties'.
          super(fields)
        end
      end

      # An image element within a document.
      class Image < Element
        factory_register 'IMAGE'
      end

      # An inline blip within a document.
      class InlineBlip < Element
        factory_register 'INLINE_BLIP'

        # The blip contained within the element [Blip].
        def blip # :nodoc:
          @context.blips[@properties['blipId']]
        end
      end

      # A form element within a document.
      # (Abstract)
      class Form < Element
        # A button form element within a document.
        class Button < Form
          factory_register 'BUTTON'
        end

        # A check form element within a document.
        class Check < Form
          factory_register 'CHECK'
        end

        # A input form element within a document.
        class Input < Form
          factory_register 'INPUT'
        end

        # A password form element within a document.
        class Password < Form
          factory_register 'PASSWORD'
        end

        # A label form element within a document.
        class Label < Form
          factory_register 'LABEL'
        end

        # A radio button form element within a document.
        class RadioButton < Form
          factory_register 'RADIO_BUTTON'
        end

        # A radio button group form element within a document.
        class RadioButtonGroup < Form
          factory_register 'RADIO_BUTTON_GROUP'
        end

        # A text-area form element within a document.
        class TextArea < Form
          factory_register 'TEXTAREA'
        end
      end
    end
  end
end
