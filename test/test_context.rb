require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Context do
  
  describe "root_wavelet()" do
    
    it "should return nil if there are no wavelets" do
      context = Context.new
      context.root_wavelet.should be_nil
    end
    
    it "should return nil if no wavelet ids end in the root suffix" do
      context = Context.new( :wavelets => { "foo" => Wavelet.new(:id => "foo"), "bar" => Wavelet.new(:id => "bar") } )
      context.root_wavelet.should be_nil
    end
    
    it "should return a wavelet if its id ends in the root suffix" do
      foo = Wavelet.new
      bar = Wavelet.new(:id => "123" + Wavelet::ROOT_ID_SUFFIX)
      context = Context.new( :wavelets => { foo.id => foo, bar.id => bar } )
      root = context.root_wavelet
      root.should == bar
    end
    
  end
  
  describe "to_json()" do
    it "should serialize the context to json without ops" do
      context, events = Robot.new.parse_json_body(TEST_JSON)
      context.to_json.should == "{\"operations\":{\"list\":[],\"javaClass\":\"java.util.ArrayList\"},\"javaClass\":\"com.google.wave.api.impl.OperationMessageBundle\"}"
    end
    it "should serialize the context to json with ops" do
      context, events = Robot.new.parse_json_body(TEST_JSON)
      wavelet = context.wavelets.values.first
      blip = context.blips[wavelet.root_blip_id]
      blip.set_text("Hello, wave!")
      context.to_json.should == "{\"operations\":{\"list\":[{\"waveletId\":\"conv+root\",\"blipId\":\"wdykLROk*13\",\"waveId\":\"wdykLROk*11\",\"property\":{\"javaClass\":\"com.google.wave.api.Range\",\"end\":1,\"start\":0},\"javaClass\":\"com.google.wave.api.impl.OperationImpl\",\"type\":\"DOCUMENT_DELETE\",\"index\":0},{\"waveletId\":\"conv+root\",\"blipId\":\"wdykLROk*13\",\"waveId\":\"wdykLROk*11\",\"property\":\"Hello, wave!\",\"javaClass\":\"com.google.wave.api.impl.OperationImpl\",\"type\":\"DOCUMENT_INSERT\",\"index\":0}],\"javaClass\":\"java.util.ArrayList\"},\"javaClass\":\"com.google.wave.api.impl.OperationMessageBundle\"}"
    end
  end
  
end