
require File.join(File.dirname(__FILE__), "helper")
describe Rave::Models::Robot do
  
  before :all do
    #Create a subclass of Robot with some handlers defined
    @class = Class.new(Rave::Models::Robot) do
      def handler1(event, context)
        @handled ||= []
        @handled << :handler1
      end
      def handler2(event, context)
        @handled ||= []
        @handled << :handler2
      end
    end
  end
  
  before :each do
    @obj = @class.new(:name => "testbot", :profile_url => "http://localhost/profile", :image_url => "http://localhost/image")
  end
  
  describe "register_handler()" do
    it "should raise an InvalidEventException for invalid event types" do
      lambda { @obj.register_handler("INVALID_EVENT", :handler1) }.should raise_error(Rave::InvalidEventException)
    end
    it "should raise an InvalidHandlerException for invalid handlers" do
      event = Rave::Models::Event::WAVELET_TIMESTAMP_CHANGED
      lambda { @obj.register_handler(event, :invalid_handler) }.should raise_error(Rave::InvalidHandlerException)
    end
    it "should add the handler to the list of handlers for the event" do
      event = Rave::Models::Event::WAVELET_BLIP_CREATED
      @obj.register_handler(event, :handler1)
      @obj.instance_eval do
        @handlers[event].should == [:handler1]
      end
    end
    it "should allow multiple handlers to be added to an event" do
      event = Rave::Models::Event::WAVELET_BLIP_REMOVED
      @obj.register_handler(event, :handler1)
      @obj.register_handler(event, :handler2)
      @obj.instance_eval do
        @handlers[event].should == [:handler1, :handler2]
      end
    end
    it "should ignore duplicate handlers" do
      event = Rave::Models::Event::WAVELET_PARTICIPANTS_CHANGED
      @obj.register_handler(event, :handler1)
      @obj.register_handler(event, :handler1)
      @obj.instance_eval do
        @handlers[event].should == [:handler1]
      end
    end
  end
  
  describe "handle_event()" do
    it "should ignore unhandled events" do
      event = Rave::Models::Event.new(:type => Rave::Models::Event::WAVELET_TITLE_CHANGED)
      @obj.handle_event(event, Context.new)
      @obj.instance_eval do
        @handled.should == nil
      end
    end
    it "should call the given handler" do
      event = Rave::Models::Event.new(:type => Rave::Models::Event::WAVELET_VERSION_CHANGED)
      @obj.register_handler(event.type, :handler1)
      @obj.handle_event(event, Context.new)
      @obj.instance_eval do
        @handled.should == [:handler1]
      end
    end
  end
  
  describe "register_cron_job()" do
    it "should add the job to the list of cron jobs" do
      @obj.register_cron_job("path", 60)
      @obj.instance_eval do
        @cron_jobs.should == [{ :path => "path", :seconds => 60}]
      end
    end
  end
  
  describe "capabilities_xml()" do
    it "should return the list of capabilities" do
      event1 = Rave::Models::Event.new(:type => Rave::Models::Event::WAVELET_TITLE_CHANGED)
      event2 = Rave::Models::Event.new(:type => Rave::Models::Event::WAVELET_VERSION_CHANGED)
      cron1 = ["path1", 60]
      cron2 = ["path2", 3600]
      @obj.register_handler(event1.type, :handler1)
      @obj.register_handler(event2.type, :handler2)
      @obj.register_cron_job(*cron1)
      @obj.register_cron_job(*cron2)
      @obj.capabilities_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><w:robot xmlns:w=\"http://wave.google.com/extensions/robots/1.0\"><w:capabilities><w:capability name=\"WAVELET_TITLE_CHANGED\"/><w:capability name=\"WAVELET_VERSION_CHANGED\"/></w:capabilities><w:crons><w:cron timeinseconds=\"60\" path=\"path1\"/><w:cron timeinseconds=\"3600\" path=\"path2\"/></w:crons><w:profile name=\"testbot\" imageurl=\"http://localhost/image\" profileurl=\"http://localhost/profile\"/></w:robot>"
    end
    
    it "should not include an empty crons tag" do
      event1 = Rave::Models::Event.new(:type => Rave::Models::Event::WAVELET_TITLE_CHANGED)
      event2 = Rave::Models::Event.new(:type => Rave::Models::Event::WAVELET_VERSION_CHANGED)
      @obj.register_handler(event1.type, :handler1)
      @obj.register_handler(event2.type, :handler2)
      @obj.capabilities_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><w:robot xmlns:w=\"http://wave.google.com/extensions/robots/1.0\"><w:capabilities><w:capability name=\"WAVELET_TITLE_CHANGED\"/><w:capability name=\"WAVELET_VERSION_CHANGED\"/></w:capabilities><w:profile name=\"testbot\" imageurl=\"http://localhost/image\" profileurl=\"http://localhost/profile\"/></w:robot>"
    end
    
    it "should not include empty profile or image urls" do
      @obj.instance_eval do
        @image_url = nil
        @profile_url = nil
      end
      event1 = Rave::Models::Event.new(:type => Rave::Models::Event::WAVELET_TITLE_CHANGED)
      event2 = Rave::Models::Event.new(:type => Rave::Models::Event::WAVELET_VERSION_CHANGED)
      cron1 = ["path1", 60]
      cron2 = ["path2", 3600]
      @obj.register_handler(event1.type, :handler1)
      @obj.register_handler(event2.type, :handler2)
      @obj.register_cron_job(*cron1)
      @obj.register_cron_job(*cron2)
      @obj.capabilities_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><w:robot xmlns:w=\"http://wave.google.com/extensions/robots/1.0\"><w:capabilities><w:capability name=\"WAVELET_TITLE_CHANGED\"/><w:capability name=\"WAVELET_VERSION_CHANGED\"/></w:capabilities><w:crons><w:cron timeinseconds=\"60\" path=\"path1\"/><w:cron timeinseconds=\"3600\" path=\"path2\"/></w:crons><w:profile name=\"testbot\"/></w:robot>"
    end
    
  end
  
  describe "profile_json()" do
    it "should return the robot's profile information in json format" do
      @obj.profile_json.should == "{\"name\":\"testbot\",\"profile_url\":\"http:\\/\\/localhost\\/profile\",\"imageurl\":\"http:\\/\\/localhost\\/image\"}"
    end
  end
  
end