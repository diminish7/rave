require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Wave do
  
  before :all do
    @class = Rave::Models::Wave
  end
  
  it_should_behave_like "UniqueId"
  
end