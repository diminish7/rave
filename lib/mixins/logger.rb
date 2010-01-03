module Rave
  module Mixins
    module Logger
      
      def logger
        if @logger.nil?
          if RUBY_PLATFORM == 'java'
            @logger = java.util.logging.Logger.getLogger(base.to_s)
          else
            require 'logger'
            #TODO: Need to be able to configure output
            @logger = Logger.new(STDOUT)
          end
        end
        @logger
      end
      
    end
  end
end

if RUBY_PLATFORM == 'java'
  #Need to alias :warn as :warning to match the java logger
  class Logger
    alias :warning :warn
  end
end