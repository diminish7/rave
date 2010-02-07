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
        
        # Returns the URL of the gadget
        def url
          @properties["url"]
        end
        # Sets the URL of the gadget to new_url
        def url=(new_url)
          @properties["url"] = new_url
        end
        
        def initialize(fields = {})
          # Gadget has 'fields' rather than 'properties'.
          super(fields)
        end
      end

      # An image element within a document.
      class Image < Element
        factory_register 'IMAGE'
        
        # Returns the caption for the image
        def caption
          @properties["caption"]
        end
        # Sets the caption of the image to new_caption
        def caption=(new_caption)
          @properties["caption"] = new_caption
        end
        # Returns the URL of the image
        def url
          @properties["url"]
        end
        # Sets teh URL of the image to new_url
        def url=(new_url)
          @properties["url"] = new_url
        end
        # Returns the height of the image
        def height
          @properties["height"]
        end
        # Sets the height of the image to new_height
        def height=(new_height)
          @properties["height"] = new_height
        end
        # Returns the width of the image
        def width
          @properties["width"]
        end
        # Sets the width of the image to new_width
        def width=(new_width)
          @properties["width"] = new_width
        end
        # Returns the attachment id of the image
        def attachment_id
          @properties["attachmentId"]
        end
        # Sets the attachment id of the image to new_attachment_id
        def attachment_id=(new_attachment_id)
          @properties["attachmentId"] = new_attachment_id
        end
          
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
        
        # Returns the label of the form element
        def label
          @properties["label"]
        end
        # Sets the label of the form element to new_label
        def label=(new_label)
          @properties["label"] = new_label
        end
        # Returns the name of the form element
        def name
          @properties["name"]
        end
        # Sets the name of the form element to new_name
        def name=(new_name)
          @properties["name"] = new_name
        end
        # Returns the value of the form element
        def value
          @properties["value"]
        end
        # Sets the value of the form element to new_value
        def value=(new_value)
          @properties["value"] = new_value
        end
        # Returns the default value of the form element
        def default_value
          @properties["defaultValue"]
        end
        # Sets the default value of the form element to new_default_value
        def default_value=(new_default_value)
          @properties["defaultValue"] = new_default_value
        end
        
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
