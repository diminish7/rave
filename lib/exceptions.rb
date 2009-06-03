module Rave
  #Exception raised when registering an invalid event
  class InvalidEventException < Exception ; end
  #Exception raised when registering an event with an invalid handler
  class InvalidHandlerException < Exception ; end
end