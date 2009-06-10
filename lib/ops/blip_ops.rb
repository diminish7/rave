#Reopen the blip class and add operation-related methods
module Rave
  module Models
    class Blip
      
      #Clear the content
      def clear
        @context.operations << Operation.new(
                                    :type => Operation::DOCUMENT_DELETE, 
                                    :blip_id => @id, 
                                    :wavelet_id => @wavelet_id, 
                                    :wave_id => @wave_id,
                                    :index => 0, 
                                    :property => 0..(@content ? @content.length : 0)
                                  )
        @content = ''
      end
      
      #Insert text at an index
      def insert_text(text, index)
        @context.operations << Operation.new(
                                    :type => Operation::DOCUMENT_INSERT, 
                                    :blip_id => @id, 
                                    :wavelet_id => @wavelet_id, 
                                    :wave_id => @wave_id,
                                    :index => index, 
                                    :property => text
                                  )
        @content = @content ? @content[0, index] + text + @content[index, @content.length - index] : text
      end
      
      #Set the content text of the blip
      def set_text(text)
        clear
        insert_text(text, 0)
      end
      
      #Deletes the text in a given range and replaces it with the given text
      def set_text_in_range(range, text)
        delete_range(range)
        insert_text(text, range.first)
      end
      
      #Appends text to the end of the content
      def append_text(text)
        @context.operations << Operation.new(
                                    :type => Operation::DOCUMENT_APPEND, 
                                    :blip_id => @id, 
                                    :wavelet_id => @wavelet_id, 
                                    :wave_id => @wave_id,
                                    :property => text
                                  )
        @content = @content + text
      end
      
      #Deletes text in the given range
      def delete_range(range)
        @context.operations << Operation.new(
                                    :type => Operation::DOCUMENT_DELETE, 
                                    :blip_id => @id, 
                                    :wavelet_id => @wavelet_id, 
                                    :wave_id => @wave_id,
                                    :index => range.first, 
                                    :property => range
                                  )
        @content = @content[0..range.first-1] + @content[range.last+1..@content.length-1]
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