#Reopen the blip class and add operation-related methods
module Rave
  module Models
    class Blip
      
      #Clear the content
      def clear
        @context.add_operation(
                                    :type => Operation::DOCUMENT_DELETE, 
                                    :blip_id => @id, 
                                    :wavelet_id => @wavelet_id, 
                                    :wave_id => @wave_id,
                                    :index => 0, 
                                    :property => 0..(@content.length)
                                  )
        @content = ''
      end
      
      #Insert text at an index
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
      end
      
      #Set the content text of the blip
      def set_text(text)
        clear
        insert_text(0, text)
      end
      
      #Deletes the text in a given range and replaces it with the given text
      def set_text_in_range(range, text)
        raise ArgumentError.new("Requires a Range, not a #{range.class.name}") unless range.kind_of? Range
        
        #Note: I'm doing this in the opposite order from the python API, because
        # otherwise, if you are setting text at the end of the content, the cursor
        # gets moved to the start of the range...
        begin # Failures in this method should give us a range error.
          insert_text(range.min, text)
        rescue IndexError => e
          raise RangeError.new(e.message)
        end
        delete_range(range.min+text.length..range.max+text.length)
      end
      
      #Appends text to the end of the content
      def append_text(text)
        @context.add_operation(
                                    :type => Operation::DOCUMENT_APPEND, 
                                    :blip_id => @id, 
                                    :wavelet_id => @wavelet_id, 
                                    :wave_id => @wave_id,
                                    :property => text
                                  )
        @content += text
      end
      
      #Deletes text in the given range
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
      end
      
      #Annotates the entire content
      def annotate_document(name, value)
        #TODO
        raise "This hasn't been implemented yet"
      end
      
      #Deletes the annotation with the given name
      def delete_annotation_by_name(name)
        #TODO
        raise "This hasn't been implemented yet"
      end
      
      #Deletes the annotations with the given key in the given range
      def delete_annotation_in_range(range, name)
        #TODO
        raise "This hasn't been implemented yet"
      end
      
      #Appends an inline blip to this blip
      def append_inline_blip
        #TODO
        raise "This hasn't been implemented yet"
      end
      
      #Deletes an inline blip from this blip
      def delete_inline_blip(blip_id)
        #TODO
        raise "This hasn't been implemented yet"
      end
      
      #Inserts an inline blip at the given position
      def insert_inline_blip(position)
        #TODO
        raise "This hasn't been implemented yet"
      end
      
      #Deletes an element at the given position
      def delete_element(position)
        #TODO
        raise "This hasn't been implemented yet"
      end
      
      #Inserts the given element in the given position
      def insert_element(position, element)
        #TODO
        raise "This hasn't been implemented yet"
      end
      
      #Replaces the element at the given position with the given element
      def replace_element(position, element)
        #TODO
        raise "This hasn't been implemented yet"
      end
      
      #Appends an element
      def append_element(element)
        #TODO
        raise "This hasn't been implemented yet"
      end
      
    end
  end
end
