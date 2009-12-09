require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Event do
  
  before :each do
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

  describe "modified_by" do
    it "should return the User object associated with the :modified_by option" do
      context = Context.new
      event = Event.create(:type => 'DOCUMENT_CHANGED', :modified_by => "Fred", :context => context)
      event.modified_by_id.should == "Fred"
      event.modified_by.should be_kind_of User
      event.modified_by.id.should == "Fred"
      context.users["Fred"].should == event.modified_by
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
end

describe Event::BlipDeletedEvent do
  describe "blip" do
    it "should return a virtual blip if it is not referenced anywhere" do
      wavelet = Wavelet.new(:id => "w+wavelet")
      context = Context.new(:wavelets => {'w+wavelet' => wavelet })
      event = described_class.new(:context => context,
        :properties => { 'blipId' => 'destroyed' })

      deleted_blip = event.blip.should be_nil
      context.blips['destroyed'].should be_nil
      event.blip_id.should == 'destroyed'
    end

    it "should return a new blip if it is already referenced from another blip" do
      blip = Blip.new(:id => 'b+blip', :child_blip_ids => ['deleted'], :wavelet_id => 'w+wavelet')
      wavelet = Wavelet.new(:id => "w+wavelet")
      context = Context.new(:blips => {'b+blip' => blip}, :wavelets => {'w+wavelet' => wavelet })
      event = described_class.new(:context => context,
        :properties => { 'blipId' => 'deleted' })

      deleted_blip = event.blip
      deleted_blip.should == blip.child_blips.first
      deleted_blip.id.should == 'deleted'
      deleted_blip.parent_blip.should == blip
      deleted_blip.child_blips.should == []
      deleted_blip.wavelet.should == wavelet
      deleted_blip.deleted?.should be_true
      deleted_blip.null?.should be_false
      deleted_blip.virtual?.should be_true
      context.blips['deleted'].should == deleted_blip
    end
  end
end

describe Event::WaveletParticipantsChangedEvent do
  before :each do
    wavelet = Wavelet.new(:id => "w+wavelet")
    context = Context.new(:wavelets => {'w+wavelet' => wavelet })
    @added_ids = ['fish', 'frog']
    @removed_ids = ['cheese']
    @event = described_class.new(:context => context,
      :properties => { 'participantsAdded' => @added_ids,
        'participantsRemoved' =>  @removed_ids })
  end

  describe "participants_added()" do
    it "should return a list of users added to the wavelet" do
      validate_user_list(@event.participants_added, @added_ids)
    end
  end

  describe "participants_removed()" do
    it "should return a list of users removed from the wavelet" do
      validate_user_list(@event.participants_removed, @removed_ids)
    end
  end
end

describe Event::BlipContributorsChangedEvent do
  before :each do
    wavelet = Wavelet.new(:id => "w+wavelet")
    context = Context.new(:wavelets => {'w+wavelet' => wavelet })
    @added_ids = ['fish', 'frog'].freeze
    @removed_ids = ['cheese'].freeze
    @event = described_class.new(:context => context,
      :properties => { 'contributorsAdded' => @added_ids,
        'contributorsRemoved' =>  @removed_ids })
  end

  describe "contributors_added()" do
    it "should return a list of users added to the blip" do
      validate_user_list(@event.contributors_added, @added_ids)
    end
  end

  describe "contributors_removed()" do
    it "should return a list of users removed from the blip" do
      validate_user_list(@event.contributors_removed, @removed_ids)
    end
  end
end
