module Rave
  #Exception raised when registering an invalid event
  class InvalidEventException < Exception ; end
  
  #Exception raised when registering an event with an invalid handler
  class InvalidHandlerException < Exception ; end

  # Raised when trying to create an object with the same ID as one that already exists.
  class DuplicatedIDError < Exception; end

  # Raised if an unimplemented method is called.
  class UnimplementedError < Exception; end
end