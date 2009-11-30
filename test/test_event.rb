require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Event do
  
  before :all do
    @class = Rave::Models::Event
  end
  
  describe "valid_event_type?()" do
    it "should return true for all valid events" do
      Rave::Models::Event::EVENT_CLASSES.each do |event|
        Rave::Models::Event.valid_event_type?(event.type).should be_true
      end
    end
    
    it "should return false for an invalid event" do
      Rave::Models::Event.valid_event_type?("INVALID_EVENT").should be_false
    end
  end
  
end