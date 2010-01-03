require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Context do

  describe "add_user()" do
    it "should add a user to the users" do
      context = Context.new()
      user = context.add_user(:id => "user")
      context.users["user"].should == user
    end
  end

  describe "users()" do
    it "should return the users passed to it" do
      user = User.new(:id => "user")
      context = Context.new(:users => { user.id => user })
      context.users[user.id].should == user
    end

    it "should contain all the wavelet participants" do
      participants = ["dave", "sue"]
      wavelet1 = Wavelet.new(:id => "wavelet1", :participants => participants)
      wavelet2 = Wavelet.new(:id => "wavelet2", :participants => [participants[0]])
      wavelet3 = Wavelet.new(:id => "wavelet3", :participants => [])
      context = Context.new(
        :wavelets => {"wavelet1" => wavelet1, "wavelet2" => wavelet2, "wavelet3" => wavelet3},
        :robot => robot_instance
      )
      participants.each do |participant|
        context.users[participant].id.should == participant
      end
    end

    it "should contain all the wavelet creators" do
      creators = ["dave", "sue"]
      wavelet1 = Wavelet.new(:id => "wavelet1", :creator => creators[0])
      wavelet2 = Wavelet.new(:id => "wavelet2", :creator => creators[0])
      wavelet3 = Wavelet.new(:id => "wavelet3", :creator => creators[1])
      context = Context.new(
        :wavelets => {"wavelet1" => wavelet1, "wavelet2" => wavelet2, "wavelet3" => wavelet3},
        :robot => robot_instance
      )
      creators.each do |participant|
        context.users[participant].id.should == participant
      end
    end

    it "should automatically contain the local robot" do
      context = Context.new(:robot => robot_instance)
      context.users[robot_instance.id].should == robot_instance
    end

    it "should contain all the blip contributors" do
      contributors = ["dave", "sue"]
      blip1 = Blip.new(:id => "blip1", :contributors => contributors)
      blip2 = Blip.new(:id => "blip2", :contributors => [contributors[0]])
      blip3 = Blip.new(:id => "blip3", :contributors => [])
      context = Context.new(
        :blips => {"blip1" => blip1, "blip2" => blip2, "blip3" => blip3},
        :robot => robot_instance
      )
      contributors.each do |contributor|
        context.users[contributor].id.should == contributor
      end
    end
  end

  describe "create_wavelet()" do
    before :each do
      @context = Context.new(:robot => robot_instance)
      @wavelet = @context.create_wavelet(["fred"])
      @wave = @wavelet.wave
      @blip = @wavelet.root_blip
    end
    
    it "should create a new generated wave" do
      @wave.should be_kind_of(Wave)
      @wave.generated?.should be_true
      @wave.wavelets.should == [@wavelet]
      @wave.root_wavelet.should == @wavelet
      @context.waves[@wave.id].should == @wave
    end
    it "should create a wavelet within the wave as its root" do
      @wavelet.should be_kind_of(Wavelet)
      @wavelet.generated?.should be_true
      @wavelet.participants.map { |user| user.to_s }.sort.should == ["fred", robot_instance.id]
      @wavelet.creator.id.should == "rusty@a.gwave.com"
      @wavelet.wave.should == @wave
      @wavelet.root?.should be_true
      @wavelet.root_blip.should == @blip
      @context.wavelets[@wavelet.id].should == @wavelet
    end
    it "should create a blip within the wavelet as its root" do
      @blip.should be_kind_of(Blip)
      @blip.generated?.should be_true
      @blip.creator.should == robot_instance
      @blip.contributors.should == [robot_instance]
      @blip.root?.should be_true
      @blip.wave.should == @wave
      @blip.wavelet.should == @wavelet
      @context.blips[@blip.id].should == @blip
    end
    it "should create an appropriate operation" do
      validate_operations(@context, [Operation::WAVELET_CREATE])
      @context.operations.last.property.should == @wavelet
    end
  end

  describe "add_blip()" do
    it "should add the blip into the context" do
      blip = Blip.new(:id => "b+blip")
      context = Context.new()
      context.blips.should == {}

      context.add_blip(blip)
      context.blips.should == { "b+blip" => blip }
    end
  end

  describe "remove_blip()" do
    it "should remove the blip from the context" do
      blip = Blip.new(:id => "b+blip")
      context = Context.new(:blips => { "b+blip" => blip })
      context.remove_blip(blip)
      context.blips.should == { }
    end
  end
  
  describe "to_json()" do
    it "should serialize the context to json without ops" do
      context, events = Robot.instance.parse_json_body(TEST_JSON)
      context.to_json.should == "{\"operations\":{\"javaClass\":\"java.util.ArrayList\",\"list\":[]},\"javaClass\":\"com.google.wave.api.impl.OperationMessageBundle\"}"
    end
    it "should serialize the context to json with ops" do
      context, events = Robot.instance.parse_json_body(TEST_JSON)
      wavelet = context.wavelets.values.first
      blip = context.blips[wavelet.root_blip_id]
      blip.set_text("Hello, wave!")
      context.to_json.should == "{\"operations\":{\"javaClass\":\"java.util.ArrayList\",\"list\":[{\"blipId\":\"wdykLROk*13\",\"index\":0,\"waveletId\":\"conv+root\",\"waveId\":\"wdykLROk*11\",\"type\":\"DOCUMENT_DELETE\",\"javaClass\":\"com.google.wave.api.impl.OperationImpl\",\"property\":{\"javaClass\":\"com.google.wave.api.Range\",\"start\":0,\"end\":1}},{\"blipId\":\"wdykLROk*13\",\"index\":-1,\"waveletId\":\"conv+root\",\"waveId\":\"wdykLROk*11\",\"type\":\"DOCUMENT_APPEND\",\"javaClass\":\"com.google.wave.api.impl.OperationImpl\",\"property\":\"Hello, wave!\"}]},\"javaClass\":\"com.google.wave.api.impl.OperationMessageBundle\"}"
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
    before :each do
      @wave = Wave.new(:id => "wave")
      @wavelet = Wavelet.new(:id => "wavelet")
      @blip = Blip.new(:id => "b+blip", :wave_id => "wave", :wavelet_id => "wavelet",
        :parent_blip_id => "b+undef", :child_blip_ids => ["b+undef1", "b+undef2", "b+undef3"])
      @context = Context.new( :blips => { @blip.id => @blip },
        :wavelets => { @wavelet.id => @wavelet }, :waves => { @wave.id => @wave })
    end

    it "should contain waves" do
      @context.waves.should == { @wave.id => @wave }
      context = @context
      @wave.instance_eval { @context.should == context }
    end
    it "should contain wavelets" do
      @context.wavelets.should == { @wavelet.id => @wavelet }
      context = @context
      @wave.instance_eval { @context.should == context }
    end
    it "should contain blips" do
      @context.blips.should == { @blip.id => @blip }
      context = @context
      @wave.instance_eval { @context.should == context }
    end
  end
end
