require 'spec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rave')

include Rave::Models

describe "UniqueId", :shared => true do
  
  it "should generate a unique id on creation" do
    obj1 = @class.new
    obj1.id.should_not be_nil
    obj2 = @class.new
    obj2.id.should_not be_nil
    obj1.id.should_not == obj2.id
    #The seed should be the same
    obj1.id[0, obj1.id.length-1].should == obj2.id[0, obj2.id.length-1]
    #The last char should be one off
    (obj1.id[obj1.id.length-1, 1].to_i + 1).should == obj2.id[obj2.id.length-1, 1].to_i
  end
  
end