require 'rubygems'
require 'rave'

module AppropriateCasey
  class Robot < Rave::Models::Robot
    
    ME = "appropriate-casey@appspot.com"
    LOGGER = java.util.logging.Logger.getLogger("Robot") unless defined?(LOGGER)
    
    #This is a very simple robot that tries to tone down yelling in waves
    def blip_submitted(event, context)
      LOGGER.info("document_changed() called!!")
      unless event.modified_by == ME || event.modified_by == "spelly@gwave.com" || event.blip.nil?
        if (blip = event.blip).content
          LOGGER.info("Evaluating blip content: #{blip.content}")
          new_sentence = true
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
            new_sentence = (char =~ /\.!?/ || (char =~ /\s/ && new_sentence))
          end
        end
      end
    end
    
  end
end
