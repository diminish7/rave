require File.join(File.dirname(__FILE__), "helper")
require 'json'

ELEMENTS_JSON = '{"elements":{"map":{"134":{"javaClass":"com.google.wave.api.FormElement","properties":{"map":{"name":"bugUrl","value":"http://code.google.com/p/google-wave-resources/issues/detail?id=","label":"","defaultValue":""},"javaClass":"java.util.HashMap"},"type":"INPUT"},"133":{"javaClass":"com.google.wave.api.FormElement","properties":{"map":{"name":"bugUrlLabel","value":"Enter your issue URL, minus the issue number:","label":"","defaultValue":"Enter your issue URL, minus the issue number:"},"javaClass":"java.util.HashMap"},"type":"LABEL"},"136":{"javaClass":"com.google.wave.api.FormElement","properties":{"map":{"name":"saveButton","value":"Save Preferences","label":"","defaultValue":"Save Preferences"},"javaClass":"java.util.HashMap"},"type":"BUTTON"}}}'

shared_examples_for "Element" do
  it "should be an appropriately classed Element" do
    @element.should be_kind_of Element
    @element.should be_kind_of described_class
  end

  it "should have no id" do
    @element.id.should == ''
  end

  describe "get()" do
    it "should return nil for non-existant properties" do
      @element['madeUpProperty'].should be_nil
      @element.get('madeUpProperty').should be_nil
    end

    it "should return default for non-existant properties" do
      @element.get('madeUpProperty', 12).should == 12
    end
  end

  describe "to_wave_json" do
    it "should be as expected" do
      pending "implementation of to_wave_json for standard classes" do
        JSON.parse(@element.to_wave_json).should == JSON.parse(@json)
      end
    end
  end
end

describe Element do
  before :each do
    @num_classes = 11 # Gadget, Image, InlineBlip + 8 form elements.
  end

  it_should_behave_like "ObjectFactory"
end

describe Element::Gadget do
  before :each do
    @url = 'http://mygadget.fish.com/'
    @element = Element.create('GADGET', 'url' => @url)
    @json = '{"javaClass":"com.google.wave.api.FormElement","type":"BUTTON,"properties":{"map":{"url":"http://mygadget.fish.com/"},"javaClass":"java.util.HashMap"}'
  end
  
  it_should_behave_like "Element"

  it "should have fields available" do
    @element.get('url').should == @url
    @element['url'].should == @url
  end
end

describe Element::Form::Button do
  before :each do
    @element = Element.create('BUTTON', "name" => "saveButton",
      "value" => "Save Preferences", "label" => "", "defaultValue" => "Save Preferences")
    @json = '{"javaClass":"com.google.wave.api.FormElement","type":"BUTTON,"properties":{"map":{"name":"saveButton","value":"Save Preferences","label":"","defaultValue":"Save Preferences"},"javaClass":"java.util.HashMap"}'
  end

  it_should_behave_like "Element"

  it "should have the properties available" do
    @element['name'].should == "saveButton"
  end
end

describe Element::InlineBlip do
  before :each do
    @element = Element.create("INLINE_BLIP", "blipId" => "blip")
    @blip = Blip.new(:id => "blip", :elements => { @element.id => @element })
    @context = Context.new(:blips => { @blip.id => @blip })
    @json = '{"javaClass":"com.google.wave.api.FormElement","type":"INLINE_BLIP,"properties":{"map":{"blipId":"blip"},"javaClass":"java.util.HashMap"}'
  end

  it_should_behave_like "Element"

  it "should have the blip available" do
    @element.blip.should == @blip
  end
end
