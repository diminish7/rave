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

  describe "create()" do
     it "should return the appropriate event sub-class for all valid events" do
      wavelet = Wavelet.new(:id => "wavelet")
      context = Context.new(:wavelets => {"wavelet" => wavelet})
      Rave::Models::Event::EVENT_CLASSES.each do |event|
        new_event = Rave::Models::Event.create(:type => event.type, :context => context)
        new_event.should be_a_kind_of event
      end
    end

    it "should raise an exception for an invalid event" do
      lambda { Rave::Models::Event.create(:type => "INVALID_EVENT",
           :context => Context.new) }.should raise_error Exception
    end

    it "should raise an exception without a context given" do
      lambda { Rave::Models::Event.create(:type => "BLIP_DELETED") }.should raise_error ArgumentError
    end

    it "should raise an exception without a type specified" do
      lambda { Rave::Models::Event.create }.should raise_error ArgumentError
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

  describe Rave::Models::Event::BlipDeletedEvent do
     describe "blip" do
       it "should return a virtual blip if it is not referenced anywhere" do
         wavelet = Wavelet.new(:id => "w+wavelet")
         context = Context.new(:wavelets => {'w+wavelet' => wavelet })
         event = Rave::Models::Event::BlipDeletedEvent.new(:context => context,
           :properties => { 'blipId' => 'b+undef' })

         deleted_blip = event.blip
         deleted_blip.id.should == 'b+undef'
         deleted_blip.parent_blip.should be_nil
         deleted_blip.child_blips.should == []
         deleted_blip.wavelet.should == wavelet
         context.blips['b+undef'].should == deleted_blip
       end

       it "should return a generated blip if it is already referenced from another blip" do
         blip = Blip.new(:id => 'b+blip', :parent_blip_id => 'b+undef', :wavelet_id => 'w+wavelet')
         wavelet = Wavelet.new(:id => "w+wavelet")
         context = Context.new(:blips => {'b+blip' => blip}, :wavelets => {'w+wavelet' => wavelet })
         event = Rave::Models::Event::BlipDeletedEvent.new(:context => context,
           :properties => { 'blipId' => 'b+undef' })
         
         deleted_blip = event.blip
         deleted_blip.should == blip.parent_blip
         deleted_blip.id.should == 'b+undef'
         deleted_blip.parent_blip.should be_nil
         deleted_blip.child_blips.should == [blip]
         deleted_blip.wavelet.should == wavelet
         context.blips['b+undef'].should == deleted_blip
       end
     end
  end
end