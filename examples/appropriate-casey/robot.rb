require 'rubygems'
require 'rave'

module AppropriateCasey
  class Robot < Rave::Models::Robot
    
    ME = "appropriate-casey@appspot.com"
    LOGGER = java.util.logging.Logger.getLogger("Robot") unless defined?(LOGGER)
    
    #This is a very simple robot that tries to tone down yelling in waves
    def document_changed(event, context)
      LOGGER.info("document_changed() called!!")
      unless event.modified_by == ME || event.modified_by == "spelly@gwave.com"
        context.blips.values.each do |blip|
          if blip.content
            LOGGER.info("Evaluating blip content: #{blip.content}")
            new_sentence = false
            blip.content.length.times do |index|
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
              if char =~ /\.!?/ || (char =~ /\s/ && new_sentence)
                new_sentence = true
              else
                new_sentence = false
              end
            end
          end
        end
      end
    end
    
  end
end
