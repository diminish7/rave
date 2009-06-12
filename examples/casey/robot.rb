require 'rubygems'
require '../../lib/rave'

module Casey
  class Robot < Rave::Models::Robot
    
    def initialize(options={})
      super(options)
      register_handler(Rave::Models::Event::DOCUMENT_CHANGED, :doc_changed)
    end
    
    def doc_changed(event, context)
      #TODO
    end
    
  end
end
