module Rave
  module Mixins
    module Logger
      
      def logger
        if @logger.nil?
          if RUBY_PLATFORM == 'java'
            @logger = java.util.logging.Logger.getLogger(self.class.to_s)
          else
            #TODO: Need to be able to configure output
            @logger = ::Logger.new(STDOUT)
          end
        end
        @logger
      end
      
    end
  end
end