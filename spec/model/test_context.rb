require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Context do

  describe "users()" do
    it "should return an empty hash if there are no users" do
      context = Context.new
      context.users.should == {}
    end

    it "should return the users passed to it" do
      user = User.new(:id => "user")
      context = Context.new(:users => { user.id => user })
      context.users.should == { user.id => user }
    end
  end

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

  describe "add_blip()" do
    it "should add the blip into the context" do
      blip = Blip.new(:id => "b+blip")
      context = Context.new()
      context.blips.should == {}
      blip.context.should be_nil

      context.add_blip(blip)
      context.blips.should == { "b+blip" => blip }
      blip.context.should == context
    end
  end
  
  describe "to_json()" do
    it "should serialize the context to json without ops" do
      context, events = Robot.new.parse_json_body(TEST_JSON)
      context.to_json.should == "{\"operations\":{\"javaClass\":\"java.util.ArrayList\",\"list\":[]},\"javaClass\":\"com.google.wave.api.impl.OperationMessageBundle\"}"
    end
    it "should serialize the context to json with ops" do
      context, events = Robot.new.parse_json_body(TEST_JSON)
      wavelet = context.wavelets.values.first
      blip = context.blips[wavelet.root_blip_id]
      blip.set_text("Hello, wave!")
      context.to_json.should == "{\"operations\":{\"javaClass\":\"java.util.ArrayList\",\"list\":[{\"blipId\":\"wdykLROk*13\",\"index\":0,\"waveletId\":\"conv+root\",\"waveId\":\"wdykLROk*11\",\"type\":\"DOCUMENT_DELETE\",\"javaClass\":\"com.google.wave.api.impl.OperationImpl\",\"property\":{\"javaClass\":\"com.google.wave.api.Range\",\"start\":0,\"end\":1}},{\"blipId\":\"wdykLROk*13\",\"index\":0,\"waveletId\":\"conv+root\",\"waveId\":\"wdykLROk*11\",\"type\":\"DOCUMENT_INSERT\",\"javaClass\":\"com.google.wave.api.impl.OperationImpl\",\"property\":\"Hello, wave!\"}]},\"javaClass\":\"com.google.wave.api.impl.OperationMessageBundle\"}"
    end
  end

  describe "print_structure()" do
    it "should return information about the wave in the context" do
      wave = Wave.new(:id => "w+wave")
      context = Context.new(:waves => { "w+wave" => wave })
      context.print_structure.should == "Wave:w+wave\n"
    end
  end

  describe "primary_wavelet" do
    it "should be the wavelet defined when creating the context" do
      wavelet = Wavelet.new(:id => "w+wavelet")
      context = Context.new(:wavelets => {'w+wavelet' => wavelet })

      context.primary_wavelet.should == wavelet
    end
  end

  describe "initialize()" do
    it "should create a virtual child blips that are only in the json as a reference" do
      blip = Blip.new(:id => "b+blip", :child_blip_ids => ["b+undef1", "b+undef2", "b+undef3"])
      context = Context.new( :blips => { blip.id => blip })

      blip.child_blips.size.should == 3
      blip.child_blips.each_with_index do |child, i|
        child.id.should == "b+undef#{i + 1}"
        child.parent_blip.should == blip
        context.blips[child.id].should == child
      end
    end

    it "should return virtual parent blip that is only in the json as reference" do
      blip = Blip.new(:id => "b+blip", :parent_blip_id => "b+undef")
      context = Context.new(:blips => { blip.id => blip })

      parent = blip.parent_blip
      parent.id.should == "b+undef"
      parent.child_blips.should == [blip]
      context.blips[parent.id].should == parent
    end
  end
end