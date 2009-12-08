require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Wavelet do
  before :each do
    # A wavelet must contain at least one blip, so create this minimum system.
    @root_blip = Blip.new(:id => "b+blip", :wavelet_id => "w+wavelet", :wave_id => "w+wave")
    @wavelet = Wavelet.new(:id => "w+wavelet", :wave_id => "w+wave", :root_blip_id => "b+blip")
    @wave = Wave.new(:id => "w+wave")
    @user = User.new(:id => "Dave")
    @context = Context.new(:wavelets => { "w+wavelet" => @wavelet },
      :waves => { "w+wave" => @wave },
      :blips => { "b+blip" => @root_blip },
      :users => { @user.id => @user })
    @json_time_fields = [:creation_time, :last_modified_time]
  end

  it_should_behave_like "Component initialize()"
  it_should_behave_like "Component id()"
  it_should_behave_like "time_from_json()"
  
  describe "final_blip()" do
    it "should be the root blip if this is the only one" do
      @wavelet.final_blip.should == @root_blip
    end

    it "should be the last one in the thread of 2" do
      new_blip = @wavelet.create_blip
      @wavelet.final_blip.should == new_blip
    end

    it "should be the last one in the thread of 4" do
      @wavelet.create_blip
      @wavelet.create_blip
      new_blip = @wavelet.create_blip
      @wavelet.final_blip.should == new_blip
    end
  end

  describe "root_blip()" do
    it "should be the initial root blip, regardless of number of replies" do
      @wavelet.root_blip.should == @root_blip
      @wavelet.create_blip
      @wavelet.root_blip.should == @root_blip
    end
  end

  describe "wave()" do
    it "should return the wave that the wavelet is in" do
      @wavelet.wave.should == @wave
    end
  end

  describe "to_s()" do
    it "should return information about the wavelet" do
      wavelet = Wavelet.new(:id => "w+wavelet", :title => "Hello!", :participants => ['Dave'])
      Context.new(:wavelets => { "w+wavelet" => wavelet })
      wavelet.to_s.should == "Wavelet:w+wavelet:Dave:Hello!"
    end

   it "should crop long content" do
      wavelet = Wavelet.new(:id => "w+wavelet", :title => 'abcdefghijklmnopqrstuvwxyz', :participants => ['Dave'])
      Context.new(:wavelets => { "w+wavelet" => wavelet })
      wavelet.to_s.should == "Wavelet:w+wavelet:Dave:abcdefghijklmnopqrstu..."
    end
  end

  describe "print_structure()" do
    it "should return the wavelet information, as well as that of its blips" do
      blip = Blip.new(:id => 'b+1', :content => 'Goodbye!', :contributors => ['Fred', 'Dave'])
      wavelet = Wavelet.new(:id => "w+wavelet", :title => "Hello!",
        :participants => %w[Elise Dave Fred Karen Sarah],
        :title => 'Hello!',
        :root_blip_id => 'b+1')
      Context.new(:blips => { 'b+1' => blip },
        :wavelets => { "w+wavelet" => wavelet })

      wavelet.print_structure.should ==<<END
#{wavelet}
  #{blip}
END
    end
  end

  describe "operations" do
    describe "create_blip()" do
      it "should create a blip at the end of the thread and an operation to the context" do
        new_blip = @wavelet.create_blip
        new_blip.parent_blip.should == @root_blip
        new_blip.wave.should == @wave
        new_blip.wavelet.should == @wavelet
        new_blip.child_blips.should == []
        @root_blip.child_blips.should == [new_blip]
        @context.blips[new_blip.id].should == new_blip
        validate_operations(@context, [Operation::WAVELET_APPEND_BLIP])
        new_blip.generated?.should be_true
        new_blip.deleted?.should be_false
        new_blip.virtual?.should be_false
      end

      it "should work correctly multiple times to create a thread" do
        new_blip1 = @wavelet.create_blip
        new_blip2 = @wavelet.create_blip
        @root_blip.child_blips.should == [new_blip1] # Not changed.
        new_blip1.child_blips.should == [new_blip2]
        new_blip2.child_blips.should == []
        new_blip2.parent_blip.should == new_blip1
        @context.blips[new_blip2.id].should == new_blip2
        validate_operations(@context, [Operation::WAVELET_APPEND_BLIP, Operation::WAVELET_APPEND_BLIP])
      end
    end
    
    describe "add_participant()" do
      it "should add a participant to the wavelet and an operation to the context" do
        @wavelet.participants.size.should == 0
        @wavelet.add_participant("Frank")
        @wavelet.participants.size.should == 1
        @wavelet.participants.first.should be_kind_of User
        @wavelet.participants.first.id.should == "Frank"
        validate_operations(@context, [Operation::WAVELET_ADD_PARTICIPANT])
      end

      it "should refuse to add a participant that is already in the wavelet" do
        @wavelet.add_participant("Dave")
        @wavelet.participants.size.should == 0
        validate_operations(@context, [])
      end
    end
  end
end
