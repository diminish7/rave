require 'spec'
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'rave')

include Rave::Models

TEST_JSON = '{"blips":{"map":{"wdykLROk*13":{"lastModifiedTime":1242079608457,"contributors":{"javaClass":"java.util.ArrayList","list":["davidbyttow@google.com"]},"waveletId":"conv+root","waveId":"wdykLROk*11","parentBlipId":null,"version":3,"creator":"davidbyttow@google.com","content":"\n","blipId":"wdykLROk*13","javaClass":"com.google.wave.api.impl.BlipData","annotations":{"javaClass":"java.util.ArrayList","list":[{"range":{"start":0,"javaClass":"com.google.wave.api.Range","end":1},"name":"user/e/davidbyttow@google.com","value":"David","javaClass":"com.google.wave.api.Annotation"}]},"elements":{"map":{},"javaClass":"java.util.HashMap"},"childBlipIds":{"javaClass":"java.util.ArrayList","list":[]}}},"javaClass":"java.util.HashMap"},"events":{"javaClass":"java.util.ArrayList","list":[{"timestamp":1242079611003,"modifiedBy":"davidbyttow@google.com","javaClass":"com.google.wave.api.impl.EventData","properties":{"map":{"participantsRemoved":{"javaClass":"java.util.ArrayList","list":[]},"participantsAdded":{"javaClass":"java.util.ArrayList","list":["monty@appspot.com"]}},"javaClass":"java.util.HashMap"},"type":"WAVELET_PARTICIPANTS_CHANGED"}]},"wavelet":{"lastModifiedTime":1242079611003,"title":"","waveletId":"conv+root","rootBlipId":"wdykLROk*13","javaClass":"com.google.wave.api.impl.WaveletData","dataDocuments":null,"creationTime":1242079608457,"waveId":"wdykLROk*11","participants":{"javaClass":"java.util.ArrayList","list":["davidbyttow@google.com","monty@appspot.com"]},"creator":"davidbyttow@google.com","version":5}}'

# Behaviour for the TimeUtils module
shared_examples_for "time_from_json()" do
  it "should convert the epoch time into a Time object" do
    time = Time.now
    context = Context.new
    @json_time_fields.each_with_index do |time_field, i|
      obj = @class.new(:id => "id#{i}", :context => context, time_field => time.to_i)
      #Should be equal down to the second
      ((obj.send(time_field) - time) < 1).should be_true
    end
  end
  
  it "should default to the current time" do
    @json_time_fields.each do |time_field|
      obj = @class.new(:id => 'id', :context => Context.new)
      ((Time.now - obj.send(time_field)) < 1).should be_true
    end
  end
  
  it "should interpret a timestamp greater than 10 digits as a float" do
    time = Time.now
    timestamp = time.to_f.to_s.gsub(".", "").to_i
    (timestamp.to_s.length > 10).should be_true
    context = Context.new
    @json_time_fields.each_with_index do |time_field, i|
      obj = @class.new(:id => "id#{i}", :context => context, time_field => timestamp)
      #Should be equal down to the millisecond now
      obj.send(time_field).should == time
    end
  end
end

# Common behaviour for descendants of Component
shared_examples_for "Component to_s()" do
  it "should return a string containing class and id" do
    comp = @class.new(:id => "fish")
    comp.to_s.should == "#{@class.name[/[^:]+$/]}:fish"
  end
end

shared_examples_for "Component initialize()" do
  it "should raise an error without an :id option" do
    lambda { @class.new() }.should raise_error ArgumentError
  end
end

shared_examples_for "Component id()" do
  it "should be equal to the initally provided :id option" do
    comp = @class.new(:id => "fish")
    comp.id.should == "fish"
  end
end

# Ensure that the operations in the queue are of the correct types.
def validate_operations(context, types)
  context.operations.length.should == types.length
  context.operations.each_with_index do |op, i|
    op.type.should == types[i]
  end
end

# Created to mimic the subclassed robot the robot-maker will create in live usage.
module MyRaveRobot
  class Robot < Rave::Models::Robot
  end
end

# This shouldn't be added generally, but is useful for catching bad uses of
# non-rave objects, such as checking the id on a nil (which is 4, so isn't an error!)
class Object
  def id
    raise "id method called on non-Rave object, #{self.class.name}"
  end
  
  def type
    raise "type method called on non-Rave object, #{self.class.name}"
  end
end
