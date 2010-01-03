require File.join(File.dirname(__FILE__), "helper")
require 'json'

shared_examples_for "Annotation" do
  describe "after creation" do
    it "should be an appropriately classed Element" do
      @annotation.should be_kind_of(described_class)
    end

    it "should have correctly set name" do
      @annotation.name.should == @name
    end
    
    it "should have correctly set type" do
      @annotation.type.should == @type
    end

    it "should have range set based on constuctor" do
      @annotation.range.should == @range
    end

    it "should have value set based on constuctor" do
      @annotation.value.should == @value
    end
  end

  describe "to_wave_json()" do
    it "should be as expected" do
      JSON.parse(@annotation.to_json).should == JSON.parse(@json)
    end
  end
end

describe Annotation do
  before :each do
    # For "ObjectFactory".
    @num_classes = 20 # 5 general classes, 7 style/, 3 user/, 3 link/, 1 conv/, lang

    # For "Annotation".
    @type = "*"
    @name = "frogs/take/over/the/world"
    @value = "yay"
    @range = 1..9
    @annotation = Annotation.create(@name, @value, @range)

    @json = '{"range":{"start":1,"javaClass":"com.google.wave.api.Range","end":9},"name":"frogs/take/over/the/world","value":"yay","javaClass":"com.google.wave.api.Annotation"}'
  end

  it_should_behave_like "ObjectFactory"
  it_should_behave_like "Annotation"

  it "should desc" do
    # TODO
  end
end

describe Annotation::Language do
  before :each do
    @type = "lang"
    @name = @type
    @value = "en"
    @range = 1..9
    @annotation = Annotation.create(@name, @value, @range)
    @json = '{"range":{"start":1,"javaClass":"com.google.wave.api.Range","end":9},"name":"lang","value":"en","javaClass":"com.google.wave.api.Annotation"}'

  end
  
  it_should_behave_like "Annotation"
end

describe Annotation::User do
  before :each do
    @type = "user/*"
    @session_id = "1ZZ654"
    @name = "user/z/#{@session_id}"
    @value = "xxx"
    @range = 1..9
    @annotation = Annotation.create(@name, @value, @range)
    @json = '{"range":{"start":1,"javaClass":"com.google.wave.api.Range","end":9},"name":"user/z/1ZZ654","value":"xxx","javaClass":"com.google.wave.api.Annotation"}'
  end

  describe "session_id" do
    it "should return the id taken from the name correctly" do
      @annotation.session_id.should == @session_id
    end
  end

  it_should_behave_like "Annotation"
end

describe Annotation::User::Selection do
  before :each do
    @type = "user/r/*"
    @session_id = "1PPPZ"
    @name = "user/r/#{@session_id}"
    @value = "yyy"
    @range = 1..3
    @annotation = Annotation.create(@name, @value, @range)
    @json = '{"range":{"start":1,"javaClass":"com.google.wave.api.Range","end":3},"name":"user/r/1PPPZ","value":"yyy","javaClass":"com.google.wave.api.Annotation"}'
  end

  it_should_behave_like "Annotation"

  describe "session_id" do
    it "should return the id taken from the name correctly" do
      @annotation.session_id.should == @session_id
    end
  end
end

