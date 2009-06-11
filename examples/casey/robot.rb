require 'rubygems'
require 'rave'

module Casey
  class Robot < Rave::Models::Robot
    
    def initialize(options={})
      super(options)
      #TODO: register handlers here.
      # e.g. If a DOCUMENT_CHANGED event should trigger a method called doc_changed(event, context):
      #      register_handler(Rave::Models::Event::DOCUMENT_CHANGED, :doc_changed)
    end
    
  end
end
