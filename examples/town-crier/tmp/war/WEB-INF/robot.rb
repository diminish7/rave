require 'rubygems'
require 'rave'

module TownCrier
  class Robot < Rave::Models::Robot
    
    ME = "town-crier@appspot.com"
    LOGGER = java.util.logging.Logger.getLogger("TownCrier")
    
    def initialize(options = {})
      super(options)
      register_cron_job(:my_cron_handler, 10)
    end
    
    def wavelet_participants_changed(event, context)
      LOGGER.info("A Participant changed!")
    end
    
    def my_cron_handler(context)
      LOGGER.info("Cron called")
    end
    
  end
end
