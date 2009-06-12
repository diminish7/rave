require 'rubygems'
require '../../lib/rave'

module Casey
  class Robot < Rave::Models::Robot
    
    def initialize(options={})
      super(options)
      register_handler(Rave::Models::Event::DOCUMENT_CHANGED, :doc_changed)
    end
    
    #This is a very simple robot that tries to tone down yelling in waves
    def doc_changed(event, context)
      context.blips.each do |blip|
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
