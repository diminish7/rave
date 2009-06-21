require 'rubygems'
require 'rave'

module AppropriateCasey
  class Robot < Rave::Models::Robot
    
    LOGGER = java.util.logging.Logger.getLogger("Robot") unless defined?(LOGGER)
    
    #This is a very simple robot that tries to tone down yelling in waves
    def document_changed(event, context)
      LOGGER.info("document_changed() called")
      context.blips.each do |blip_id, blip|
        #Get rid of multiple exclamation points, replace with a period
        if blip.content
          content = blip.content.gsub(/!+/, ".")
          ends_with_period = content[content.length-1, 1] == "."
          trailing_whitespace = (index = content =~ /\s$/) ? content[index, content.length-1] : nil
          #Set the case on each sentence
          appropriate = content.split(".").collect do |sentence|
            next if sentence.nil? || sentence.strip.empty?
            sentence.strip!
            sentence[0, 1].upcase + sentence[1, sentence.length-1].downcase
          end.join(". ")
          appropriate += "." if ends_with_period
          appropriate += trailing_whitespace if trailing_whitespace
          LOGGER.info("Setting blip's text to #{appropriate.to_s}")
          blip.set_text(appropriate)
        else
          LOGGER.info("Blips contents were nil")
        end
      end
    end
    
  end
end
