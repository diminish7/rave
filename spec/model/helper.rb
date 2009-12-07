require 'spec'
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'rave')

include Rave::Models

TEST_JSON = '{"blips":{"map":{"wdykLROk*13":{"lastModifiedTime":1242079608457,"contributors":{"javaClass":"java.util.ArrayList","list":["davidbyttow@google.com"]},"waveletId":"conv+root","waveId":"wdykLROk*11","parentBlipId":null,"version":3,"creator":"davidbyttow@google.com","content":"\n","blipId":"wdykLROk*13","javaClass":"com.google.wave.api.impl.BlipData","annotations":{"javaClass":"java.util.ArrayList","list":[{"range":{"start":0,"javaClass":"com.google.wave.api.Range","end":1},"name":"user/e/davidbyttow@google.com","value":"David","javaClass":"com.google.wave.api.Annotation"}]},"elements":{"map":{},"javaClass":"java.util.HashMap"},"childBlipIds":{"javaClass":"java.util.ArrayList","list":[]}}},"javaClass":"java.util.HashMap"},"events":{"javaClass":"java.util.ArrayList","list":[{"timestamp":1242079611003,"modifiedBy":"davidbyttow@google.com","javaClass":"com.google.wave.api.impl.EventData","properties":{"map":{"participantsRemoved":{"javaClass":"java.util.ArrayList","list":[]},"participantsAdded":{"javaClass":"java.util.ArrayList","list":["monty@appspot.com"]}},"javaClass":"java.util.HashMap"},"type":"WAVELET_PARTICIPANTS_CHANGED"}]},"wavelet":{"lastModifiedTime":1242079611003,"title":"","waveletId":"conv+root","rootBlipId":"wdykLROk*13","javaClass":"com.google.wave.api.impl.WaveletData","dataDocuments":null,"creationTime":1242079608457,"waveId":"wdykLROk*11","participants":{"javaClass":"java.util.ArrayList","list":["davidbyttow@google.com","monty@appspot.com"]},"creator":"davidbyttow@google.com","version":5}}'

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
