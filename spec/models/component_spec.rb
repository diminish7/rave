require File.join(File.dirname(__FILE__), "helper")


describe Component do
  it_should_behave_like "Component to_s()"
  it_should_behave_like "Component initialize()"
  it_should_behave_like "Component id()"
end


