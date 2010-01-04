unless RUBY_PLATFORM == 'java'
  require 'logger'
  #Need to alias :warn as :warning to match the java logger
  class Logger
    alias :warning :warn
  end
end