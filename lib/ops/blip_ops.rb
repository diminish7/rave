module Rave
  module Models
    class Blip
      # Reopen the blip class and add operation-related methods

      VALID_FORMATS = [:plain, :html, :textile] # :nodoc: For set_text/append_text
      
      # Clear the content.
      def clear
        return if content.empty? # No point telling the server to clear an empty blip.
        @context.add_operation(
                                    :type => Operation::DOCUMENT_DELETE, 
                                    :blip_id => @id, 
                                    :wavelet_id => @wavelet_id,
                                    :wave_id => @wave_id,
                                    :index => 0,
                                    :property => 0..(@content.length)
                                  )
        @content = ''
        # TODO: Remove all annotations.
      end
      
      # Insert text at an index.
      def insert_text(index, text)
        @context.add_operation(
                                    :type => Operation::DOCUMENT_INSERT, 
                                    :blip_id => @id, 
                                    :wavelet_id => @wavelet_id, 
                                    :wave_id => @wave_id,
                                    :index => index, 
                                    :property => text
                                  )
        @content.insert(index, text)
        # TODO: Shift annotations.
      end
      
      # Set the content text of the blip.
      #
      # === Options
      # :+format+ - Format of the text, which can be any one of:
      # * :+html+ - Text marked up with HTML.
      # * :+plain+ - Plain text (default).
      # * :+textile+ - Text marked up with textile.
      def set_text(text, options = {})
        clear
        append_text(text, options)
      end
      
      # Deletes the text in a given range and replaces it with the given text.
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
      end
      
      # Appends text to the end of the blip's current content.
      # 
      # === Options
      # :+format+ - Format of the text, which can be any one of:
      # * :+html+ - Text marked up with HTML.
      # * :+plain+ - Plain text (default).
      # * :+textile+ - Text marked up with textile.
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
        
        @context.add_operation(
                                    :type => type,
                                    :blip_id => @id, 
                                    :wavelet_id => @wavelet_id, 
                                    :wave_id => @wave_id,
                                    :property => text # Markup sent to Wave.
                                  )
        # TODO: Add annotations for the tags we removed?
        @content += plain_text # Plain text added to text field.
      end
      
      # Deletes text in the given range.
      def delete_range(range)
        raise ArgumentError.new("Requires a Range, not a #{range.class.name}") unless range.kind_of? Range
        
        @context.add_operation(
                                    :type => Operation::DOCUMENT_DELETE, 
                                    :blip_id => @id, 
                                    :wavelet_id => @wavelet_id, 
                                    :wave_id => @wave_id,
                                    :index => range.min,
                                    :property => range
                                  )
         @content[range] = ''
         # TODO: Shift annotations.
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
      #
      # NOT IMPLEMENTED
      def append_inline_blip
        raise NotImplementedError
      end
      
      # Deletes an inline blip from this blip.
      #
      # NOT IMPLEMENTED
      def delete_inline_blip(blip_id)
        raise NotImplementedError
      end
      
      # Inserts an inline blip at the given position.
      #
      # NOT IMPLEMENTED
      def insert_inline_blip(position)
        raise NotImplementedError
      end
      
      # Deletes an element at the given position.
      #
      # NOT IMPLEMENTED
      def delete_element(position)
        raise NotImplementedError
      end
      
      # Inserts the given element in the given position.
      #
      # NOT IMPLEMENTED
      def insert_element(position, element)
        raise NotImplementedError
      end
      
      # Replaces the element at the given position with the given element.
      #
      # NOT IMPLEMENTED
      def replace_element(position, element)
        raise NotImplementedError
      end
      
      # Appends an element
      # 
      # NOT IMPLEMENTED
      def append_element(element)
        raise NotImplementedError
      end

    protected
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
    end
  end
end
