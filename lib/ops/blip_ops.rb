module Rave
  module Models
    class Blip
      # Reopen the blip class and add operation-related methods

      VALID_FORMATS = [:plain, :html, :textile] # :nodoc: For set_text/append_text

      # Clear the content.
      def clear
        return if content.empty? # No point telling the server to clear an empty blip.
        text = delete_range(0..(@content.length))
        udpate_title_if_needed
        text
      end

      # Insert text at an index.
      def insert_text(index, text)
        add_operation(:type => Operation::DOCUMENT_INSERT, :index => index, :property => text)
        @content.insert(index, text)
        # TODO: Shift annotations.
        udpate_title_if_needed
        text
      end

      # Set the content text of the blip.
      #
      # === Options
      # :+format+ - Format of the text, which can be any one of:
      # * :+html+ - Text marked up with HTML.
      # * :+plain+ - Plain text (default).
      # * :+textile+ - Text marked up with textile.
      #
      # Returns: An empty string [String]
      def set_text(text, options = {})
        clear
        udpate_title_if_needed
        append_text(text, options)
      end

      # Deletes the text in a given range and replaces it with the given text.
      # Returns: The text altered [String]
      def set_text_in_range(range, text)
        raise ArgumentError.new("Requires a Range, not a #{range.class.name}") unless range.kind_of? Range

        #Note: I'm doing this in the opposite order from the python API, because
        # otherwise, if you are setting text at the end of the content, the cursor
        # gets moved to the start of the range...
        unless text.empty?
          begin # Failures in this method should give us a range error.
            insert_text(range.min, text)
          rescue IndexError => e
            raise RangeError.new(e.message)
          end
        end
        delete_range(range.min+text.length..range.max+text.length)
        # TODO: Shift annotations.
        udpate_title_if_needed
        text
      end

      # Appends text to the end of the blip's current content.
      #
      # === Options
      # :+format+ - Format of the text, which can be any one of:
      # * :+html+ - Text marked up with HTML.
      # * :+plain+ - Plain text (default).
      # * :+textile+ - Text marked up with textile.
      #
      # Returns: The new content string [String]
      def append_text(text, options = {})
        format = options[:format] || :plain
        raise BadOptionError.new(:format, VALID_FORMATS, format) unless VALID_FORMATS.include? format

        plain_text = text

        if format == :textile
          text = RedCloth.new(text).to_html
          format = :html # Can now just treat it as HTML.
        end

        if format == :html
          type = Operation::DOCUMENT_APPEND_MARKUP
          plain_text = strip_html_tags(text)
        else
          type = Operation::DOCUMENT_APPEND
        end

        add_operation(:type => type, :property => text)
        # TODO: Add annotations for the tags we removed?
        @content += plain_text # Plain text added to text field.
        udpate_title_if_needed
        @content.dup
      end

      # Deletes text in the given range.
      # Returns: An empty string [String]
      def delete_range(range)
        raise ArgumentError.new("Requires a Range, not a #{range.class.name}") unless range.kind_of? Range

        add_operation(:type => Operation::DOCUMENT_DELETE, :index => range.min, :property => range)

        @content[range] = ''
        # TODO: Shift and/or delete annotations.
        udpate_title_if_needed
        ''
      end

      # Annotates the entire content.
      #
      # NOT IMPLEMENTED
      def annotate_document(name, value)
        raise NotImplementedError
      end

      # Deletes the annotation with the given name.
      #
      # NOT IMPLEMENTED
      def delete_annotation_by_name(name)
        raise NotImplementedError
      end

      # Deletes the annotations with the given key in the given range.
      #
      # NOT IMPLEMENTED
      def delete_annotation_in_range(range, name)
        raise NotImplementedError
      end

      # Appends an inline blip to this blip.
      # Returns: Blip created by operation [Blip]
      def append_inline_blip
        # TODO: What happens if there already is an element at end of content?
        blip = Blip.new(:wave_id => @wave_id, :wavelet_id => @wavelet_id)
        @context.add_blip(blip)
        element = Element::InlineBlip.new('blipId' => blip.id)
        element.context = @context
        @elements[@content.length] = element
        add_operation(:type => Operation::DOCUMENT_INLINE_BLIP_APPEND, :property => blip)

        blip
      end

      # Deletes an inline blip from this blip.
      # +value+:: Inline blip to delete [Blip]
      #
      # Returns: Blip ID of the deleted blip [String]
      def delete_inline_blip(blip) # :nodoc:
        element = @elements.values.find { |e| e.kind_of?(Element::InlineBlip) and e.blip == blip }
        raise "Blip '#{blip.id}' is not an inline blip of blip '#{id}'" if element.nil?
        #element.blip.destroy_me # TODO: How to deal with children?
        @elements.delete_if { |pos, el| el == element }
        add_operation(:type => Operation::DOCUMENT_INLINE_BLIP_DELETE, :property => blip.id)

        blip.id
      end

      # Inserts an inline blip at the given position.
      # Returns: Blip element created by operation [Blip]
      def insert_inline_blip(position)
        # TODO: Complain if element does exist at that position.
        blip = Blip.new(:wave_id => @wave_id, :wavelet_id => @wavelet_id)
        @context.add_blip(blip)
        element = Element::InlineBlip.new('blipId' => blip.id)
        element.context = @context
        @elements[@content.length] = element
        add_operation(:type => Operation::DOCUMENT_INLINE_BLIP_INSERT, :index => position, :property => blip)

        blip
      end

      # Deletes an element at the given position.
      def delete_element(position)
        element = @elements[position]
        case element
        when Element::InlineBlip
          return delete_inline_blip(element.blip)
        when Element
          @elements[position] = nil
          add_operation(:type => Operation::DOCUMENT_ELEMENT_DELETE, :index => position)
        else
          raise "No element to delete at position #{position}"
        end

        self
      end

      # Inserts the given element in the given position.
      def insert_element(position, element)
        # TODO: Complain if element does exist at that position.
        @elements[position] = element
        add_operation(:type => Operation::DOCUMENT_ELEMENT_INSERT, :index => position, :property => element)

        element
      end

      # Replaces the element at the given position with the given element.
      def replace_element(position, element)
        # TODO: Complain if element does not exist at that position.
        @elements[position] = element
        add_operation(:type => Operation::DOCUMENT_ELEMENT_REPLACE, :index => position, :property => element)

        element
      end

      # Appends an element
      def append_element(element)
        # TODO: What happens if there already is an element at end of content?
        @elements[@content.length] = element
        add_operation(:type => Operation::DOCUMENT_ELEMENT_APPEND, :property => element)

        element
      end

    protected
      def add_operation(options) # :nodoc:
        @context.add_operation(options.merge(:blip_id => @id, :wavelet_id => @wavelet_id, :wave_id => @wave_id))
      end

      # Strips all HTML tags from a string, returning what it would look like unformatted.
      def strip_html_tags(text) # :nodoc:
        # Replace existing newlines/tabs with spaces, since they don't affect layout.
        str = text.gsub(/[\n\t]/, ' ')
        # Replace all <br /> with a newline.
        str.gsub!(/<br\s*\/>\s*/, "\n")
        # Put newline where are </h?>, </p> </div>, unless at the end.
        str.gsub!(/<\/(?:h\d|p|div)>\s*(?!$)/, "\n")
        # Remove all tags.
        str.gsub!(/<\/?[^<]*>/, '')
        # Remove spaces at each end.
        str.gsub!(/^ +| +$/, '')
        # Compress all adjacent spaces into a single space.
        str.gsub(/ {2,}/, ' ')
      end

      #Update the title of the wavelet from the first line of content if this is the root blip
      def udpate_title_if_needed
        if self.root? && self.wavelet
          new_title = if @content.nil? || @content.empty?
            ''
          else
            @content.split("\n").first
          end
          self.wavelet.send(:set_title_locally, new_title)
        end
      end

    end
  end
end
