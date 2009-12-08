require 'rubygems'
require 'rave'

module MyRaveRobot
  class Robot < Rave::Models::Robot
    #This is a very simple robot that tries to tone down yelling in waves
    def blip_submitted(event, context)
      blip = event.blip
      if blip.content
        LOGGER.info("Evaluating blip content: #{blip.content}")
        new_sentence = true
        do_update = false
        content = blip.content
        content.length.times do |index|
          range = index..index+1
          char = content[index, 1]
          if char =~ /[A-Z]/ && !new_sentence
            content = replace_char_at(index, content, char.downcase)
            do_update = true
          elsif char =~ /[a-z]/ && new_sentence
            content = replace_char_at(index, content, char.upcase)
            do_update = true
          elsif char == "!"
            if new_sentence
              content = replace_char_at(index, content, "")
              do_update = true
            else
              content = replace_char_at(index, content, ".")
              do_update = true
            end
          end
          new_sentence = (char =~ /\.!?/ || (char =~ /\s/ && new_sentence))
        end
        blip.set_text(content) if do_update
      end
    end
  private
    
    def replace_char_at(index, string, new_char)
      string[0..(index-1)] + new_char + string[(index+1)..-1]
    end
    
  end
end
