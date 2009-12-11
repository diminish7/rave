module Rave
  #Exception raised when registering an invalid event
  class InvalidEventException < Exception ; end
  
  #Exception raised when registering an event with an invalid handler
  class InvalidHandlerException < Exception ; end

  # Raised when trying to create an object with the same ID as one that already exists.
  class DuplicatedIDError < Exception; end

  # Raised if an unimplemented method is called.
  class NotImplementedError < Exception; end

  # A method option was not one of the values allowed.
  class BadOptionError < ArgumentError
    def initialize(option_name, valid_options, received) # :nodoc:
      super("#{option_name.inspect} option must be one of #{valid_options.inspect}, not #{received.inspect}")
    end
  end
end