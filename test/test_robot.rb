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
    @obj = @class.new
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
  
end