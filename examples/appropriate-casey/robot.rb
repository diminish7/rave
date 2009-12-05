require 'rubygems'
require 'rave'

module MyRaveRobot
  class Robot < Rave::Models::Robot
   
    #This is a very simple robot that tries to tone down yelling in waves
    def document_changed(event, context)
      unless [id, "spelly@gwave.com"].include event.modified_by
          new_sentence = true
          event.blip.content.length.times do |index|
            range = index..index+1
            char = blip.content[index, 1]
            if char =~ /[A-Z]/ && !new_sentence
              blip.set_text_in_range(range, char.downcase)
            elsif char =~ /[a-z]/ && new_sentence
              blip.set_text_in_range(range, char.upcase)
            elsif char == "!"
              if new_sentence
                blip.delete_range(range)
              else
                blip.set_text_in_range(range, ".")
              end
            end
            new_sentence = (char =~ /\.!?/ || (char =~ /\s/ && new_sentence))
          end
        end
      end
    end
  end
end
