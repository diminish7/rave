
require File.join(File.dirname(__FILE__), "helper")
describe Rave::Models::Robot do
  
  before :each do
    #Create a subclass of Robot with some handlers defined
    robot_class = Class.new(Rave::Models::Robot) do
      def document_changed(event, context)
        @handled ||= []
        @handled << :document_changed
      end
      def handler1(event, context)
        @handled ||= []
        @handled << :handler1
      end
      def handler2(event, context)
        @handled ||= []
        @handled << :handler2
      end
      def helper()
        @handled ||= []
        @handled << :helper
      end
    end

    # Ensure that we read the test file, rather than the default one.
    robot_class::CONFIG_FILE.sub!(/.*/, File.join(File.dirname(__FILE__), 'config.yaml'))

    @obj = robot_class.instance
  end
  
  describe "register_handler()" do
    it "should automatically register correctly named handlers" do
      @obj.instance_eval do
        event = Rave::Models::Event::DocumentChanged.type
        @handlers[event].should == [:document_changed]
      end
    end
    it "should raise an InvalidEventException for invalid event types" do
      lambda { @obj.register_handler("INVALID_EVENT", :handler1) }.should raise_error(Rave::InvalidEventException)
    end
    it "should raise an InvalidHandlerException for invalid handlers" do
      event = Rave::Models::Event::WaveletTimestampChanged.type
      lambda { @obj.register_handler(event, :invalid_handler) }.should raise_error(Rave::InvalidHandlerException)
    end
    it "should add the handler to the list of handlers for the event" do
      event = Rave::Models::Event::WaveletBlipCreated.type
      @obj.register_handler(event, :handler1)
      @obj.instance_eval do
        @handlers[event].should == [:handler1]
      end
    end
    it "should allow multiple handlers to be added to an event" do
      event = Rave::Models::Event::WaveletBlipRemoved.type
      @obj.register_handler(event, :handler1)
      @obj.register_handler(event, :handler2)
      @obj.instance_eval do
        @handlers[event].should == [:handler1, :handler2]
      end
    end
    it "should ignore duplicate handlers" do
      event = Rave::Models::Event::WaveletParticipantsChanged.type
      @obj.register_handler(event, :handler1)
      @obj.register_handler(event, :handler1)
      @obj.instance_eval do
        @handlers[event].should == [:handler1]
      end
    end
  end
  
  describe "handle_event()" do
    it "should ignore unhandled events" do
      event = Rave::Models::Event.create(Rave::Models::Event::WaveletTitleChanged.type, :context => Context.new)
      @obj.handle_event(event, Context.new)
      @obj.instance_eval do
        @handled.should == nil
      end
    end
    it "should call the given handler" do
      event = Rave::Models::Event.create(Rave::Models::Event::WaveletVersionChanged.type, :context => Context.new)
      @obj.register_handler(event.type, :handler1)
      @obj.handle_event(event, Context.new)
      @obj.instance_eval do
        @handled.should == [:handler1]
      end
    end
  end
  
  describe "register_cron_job()" do
    it "should add the job to the list of cron jobs" do
      @obj.register_cron_job(:cron_handler, 60)
      @obj.instance_eval do
        @cron_jobs.should == [{ :path => "/_wave/cron/cron_handler", :handler => :cron_handler, :seconds => 60}]
      end
    end
  end
  
  describe "capabilities_xml()" do
    it "should return the list of capabilities" do
      event1 = Rave::Models::Event.create(Rave::Models::Event::WaveletTitleChanged.type, :context => Context.new)
      event2 = Rave::Models::Event.create(Rave::Models::Event::WaveletVersionChanged.type, :context => Context.new)
      cron1 = [:cron_handler1, 60]
      cron2 = [:cron_handler2, 3600]
      @obj.register_handler(event1.type, :handler1)
      @obj.register_handler(event2.type, :handler2)
      @obj.register_cron_job(*cron1)
      @obj.register_cron_job(*cron2)
      #TODO: XML is in different order on MRI, need to parse and compare nodes
      @obj.capabilities_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><w:robot xmlns:w=\"http://wave.google.com/extensions/robots/1.0\"><w:version>1</w:version><w:capabilities><w:capability name=\"DOCUMENT_CHANGED\"/><w:capability name=\"WAVELET_TITLE_CHANGED\"/><w:capability name=\"WAVELET_VERSION_CHANGED\"/></w:capabilities><w:crons><w:cron path=\"/_wave/cron/cron_handler1\" timerinseconds=\"60\"/><w:cron path=\"/_wave/cron/cron_handler2\" timerinseconds=\"3600\"/></w:crons><w:profile name=\"testbot\" imageurl=\"http://localhost/image.png\" profileurl=\"http://localhost/profile\"/></w:robot>"
    end
    
    it "should not include an empty crons tag" do
      event1 = Rave::Models::Event.create(Rave::Models::Event::WaveletTitleChanged.type, :context => Context.new)
      event2 = Rave::Models::Event.create(Rave::Models::Event::WaveletVersionChanged.type, :context => Context.new)
      @obj.register_handler(event1.type, :handler1)
      @obj.register_handler(event2.type, :handler2)
      #TODO: XML is in different order on MRI, need to parse and compare nodes
      @obj.capabilities_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><w:robot xmlns:w=\"http://wave.google.com/extensions/robots/1.0\"><w:version>1</w:version><w:capabilities><w:capability name=\"DOCUMENT_CHANGED\"/><w:capability name=\"WAVELET_TITLE_CHANGED\"/><w:capability name=\"WAVELET_VERSION_CHANGED\"/></w:capabilities><w:profile name=\"testbot\" imageurl=\"http://localhost/image.png\" profileurl=\"http://localhost/profile\"/></w:robot>"
    end
    
    it "should not include empty profile or image urls" do
      @obj.instance_eval do
        @image_url = nil
        @profile_url = nil
      end
      event1 = Rave::Models::Event.create(Rave::Models::Event::WaveletTitleChanged.type, :context => Context.new)
      event2 = Rave::Models::Event.create(Rave::Models::Event::WaveletVersionChanged.type, :context => Context.new)
      cron1 = [:cron_handler1, 60]
      cron2 = [:cron_handler2, 3600]
      @obj.register_handler(event1.type, :handler1)
      @obj.register_handler(event2.type, :handler2)
      @obj.register_cron_job(*cron1)
      @obj.register_cron_job(*cron2)
      #TODO: XML is in different order on MRI, need to parse and compare nodes
      @obj.capabilities_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><w:robot xmlns:w=\"http://wave.google.com/extensions/robots/1.0\"><w:version>1</w:version><w:capabilities><w:capability name=\"DOCUMENT_CHANGED\"/><w:capability name=\"WAVELET_TITLE_CHANGED\"/><w:capability name=\"WAVELET_VERSION_CHANGED\"/></w:capabilities><w:crons><w:cron path=\"/_wave/cron/cron_handler1\" timerinseconds=\"60\"/><w:cron path=\"/_wave/cron/cron_handler2\" timerinseconds=\"3600\"/></w:crons><w:profile name=\"testbot\"/></w:robot>"
    end
    
  end
  
  describe "profile_json()" do
    it "should return the robot's profile information in json format" do
      JSON.parse(@obj.profile_json).should == {
                                                "name" => "testbot",
                                                "imageUrl" => "http://localhost/image.png",
                                                "profileUrl" => "http://localhost/profile",
                                                "javaClass" => "com.google.wave.api.ParticipantProfile"
                                              }
    end
  end
  
  describe "parse_json_body()" do
    it "should parse the json into context and events" do
      #Response JSON taken from Google's Python tests
      context, events = @obj.parse_json_body(TEST_JSON)
      #Test blips
      blips = context.blips
      blips.length.should == 1
      blip = blips.values.first
      blip.id.should == 'wdykLROk*13'
      blip.wave_id.should == 'wdykLROk*11'
      blip.wavelet_id.should == 'conv+root'
      #Test events
      events.length.should == 1
      event = events.first
      event.type.should == Rave::Models::Event::WaveletParticipantsChanged.type
      event.participants_removed.should == []
      validate_user_list(event.participants_added, ['monty@appspot.com'])
    end
  end
  
end
