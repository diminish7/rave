module Rave
  module Models
    class Element
      include Mixins::ObjectFactory

      def initialize(properties = {})
        @properties = properties
      end

      def get(key, default = nil)
        if @properties.has_key? key
          @properties[key]
        else
          default
        end
      end

      def set(key, value)
        @properties[key] = value
      end

      alias_method :[]=, :set
      
      def [](key)
        get(key)
      end

      # A Google Gadget element within a document.
      class Gadget < Element
        TYPE = 'GADGET'

        factory_register

        attr_reader :url
        def url # :nodoc:
          @url.dup
        end

        def initialize(fields = {})
          @url = fields['url']
          fields = fields.dup
          fields.delete 'url'
          super(fields)
        end
      end

      # An image element within a document.
      class Image < Element
        TYPE = 'IMAGE'

        factory_register
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
