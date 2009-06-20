require 'rubygems'
require 'rave'

module AppropriateCasey
  class Robot < Rave::Models::Robot
    
    LOGGER = java.util.logging.Logger.getLogger("Robot")
    
    #This is a very simple robot that tries to tone down yelling in waves
    def document_changed(event, context)
      LOGGER.info("document_changed() called")
      context.blips.each do |blip_id, blip|
        #Get rid of multiple exclamation points, replace with a period
        content = blip.content.gsub(/!+/, ".")
        #Set the case on each sentence
        appropriate = content.split(".").collect do |sentence|
          sentence.strip!
          sentence[0, 1].upcase + sentence[1, sentence.length-1].downcase
        end.join(". ")+"."
        blip.set_text(appropriate)
      end
    end
    
  end
end
