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
        #optimistically set the text
      end
      
    end
  end
end