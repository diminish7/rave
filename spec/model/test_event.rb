require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Event do
  
  before :all do
    @class = Rave::Models::Event
    @json_time_fields = [:timestamp]
  end
  
  it_should_behave_like "time_from_json()"
  
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

  describe "create()" do
     it "should return the appropriate event sub-class for all valid events" do
      Rave::Models::Event::EVENT_CLASSES.each do |event|
        Rave::Models::Event.create(:type => event.type).should be_a_kind_of event
      end
    end

    it "should raise an exception for an invalid event" do
      lambda { Rave::Models::Event.create(:type => "INVALID_EVENT") }.should raise_error Exception
    end

    it "should raise an exception without a type specified" do
      lambda { Rave::Models::Event.create }.should raise_error Exception
    end
  end

  describe "type()" do
    it "should raise an exception when called on Event" do
      lambda { Rave::Models::Event.type }.should raise_error Exception
    end

    it "should return the correct type for a BlipSubmittedEvent" do
      Rave::Models::Event::BlipSubmittedEvent.type.should == 'BLIP_SUBMITTED'
    end
  end
  
end