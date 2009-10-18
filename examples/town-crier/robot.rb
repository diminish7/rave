require 'rubygems'
require 'rave'

module TownCrier
  class Robot < Rave::Models::Robot
    
    ME = "town-crier@appspot.com"
    
    def initialize(options = {})
      super(options)
      register_cron_job(:my_cron_handler, 10``)
    end
    
    def my_cron_handler(context)
      
    end
    
  end
end
