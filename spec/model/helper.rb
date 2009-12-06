require 'spec'
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'rave')

include Rave::Models

TEST_JSON = '{"blips":{"map":{"wdykLROk*13":{"lastModifiedTime":1242079608457,"contributors":{"javaClass":"java.util.ArrayList","list":["davidbyttow@google.com"]},"waveletId":"conv+root","waveId":"wdykLROk*11","parentBlipId":null,"version":3,"creator":"davidbyttow@google.com","content":"\n","blipId":"wdykLROk*13","javaClass":"com.google.wave.api.impl.BlipData","annotations":{"javaClass":"java.util.ArrayList","list":[{"range":{"start":0,"javaClass":"com.google.wave.api.Range","end":1},"name":"user/e/davidbyttow@google.com","value":"David","javaClass":"com.google.wave.api.Annotation"}]},"elements":{"map":{},"javaClass":"java.util.HashMap"},"childBlipIds":{"javaClass":"java.util.ArrayList","list":[]}}},"javaClass":"java.util.HashMap"},"events":{"javaClass":"java.util.ArrayList","list":[{"timestamp":1242079611003,"modifiedBy":"davidbyttow@google.com","javaClass":"com.google.wave.api.impl.EventData","properties":{"map":{"participantsRemoved":{"javaClass":"java.util.ArrayList","list":[]},"participantsAdded":{"javaClass":"java.util.ArrayList","list":["monty@appspot.com"]}},"javaClass":"java.util.HashMap"},"type":"WAVELET_PARTICIPANTS_CHANGED"}]},"wavelet":{"lastModifiedTime":1242079611003,"title":"","waveletId":"conv+root","rootBlipId":"wdykLROk*13","javaClass":"com.google.wave.api.impl.WaveletData","dataDocuments":null,"creationTime":1242079608457,"waveId":"wdykLROk*11","participants":{"javaClass":"java.util.ArrayList","list":["davidbyttow@google.com","monty@appspot.com"]},"creator":"davidbyttow@google.com","version":5}}'

describe "time_from_json()", :shared => true do
  it "should convert the epoch time into a Time object" do
    time = Time.now
    @json_time_fields.each do |time_field|
      obj = @class.new(time_field => time.to_i)
      #Should be equal down to the second
      ((obj.send(time_field) - time) < 1).should be_true
    end
  end
  
  it "should default to the current time" do
    @json_time_fields.each do |time_field|
      obj = @class.new
      ((Time.now - obj.send(time_field)) < 1).should be_true
    end
  end
  
  it "should interpret a timestamp greater than 10 digits as a float" do
    time = Time.now
    timestamp = time.to_f.to_s.gsub(".", "").to_i
    (timestamp.to_s.length > 10).should be_true
    @json_time_fields.each do |time_field|
      obj = @class.new(time_field => timestamp)
      #Should be equal down to the millisecond now
      obj.send(time_field).should == time
    end
  end
end

def validate_operations(context, types)
  context.operations.length.should == types.length
  context.operations.each_with_index do |op, i|
    op.type.should == types[i]
  end
end
