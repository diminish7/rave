require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Wavelet do
  before :each do
    # A wavelet must contain at least one blip, so create this minimum system.
    @root_blip = Blip.new(:id => "b+blip", :wavelet_id => "w+wavelet", :wave_id => "w+wave")
    @wavelet = Wavelet.new(:id => "w+wavelet", :wave_id => "w+wave", :root_blip_id => "b+blip")
    @wave = Wave.new(:id => "w+wave")
    @user = User.new(:id => "dave")
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
      wavelet = Wavelet.new(:id => "w+wavelet", :title => "Hello!", :participants => ['dave'])
      Context.new(:wavelets => { "w+wavelet" => wavelet }, :robot => robot_instance)
      wavelet.to_s.should == "Wavelet:w+wavelet:dave:Hello!"
    end

   it "should crop long content" do
      wavelet = Wavelet.new(:id => "w+wavelet", :title => 'abcdefghijklmnopqrstuvwxyz', :participants => ['dave'])
      Context.new(:wavelets => { "w+wavelet" => wavelet }, :robot => robot_instance)
      wavelet.to_s.should == "Wavelet:w+wavelet:dave:abcdefghijklmnopqrstu..."
    end
  end

  describe "print_structure()" do
    it "should return the wavelet information, as well as that of its blips" do
      blip = Blip.new(:id => 'b+1', :content => 'Goodbye!', :contributors => ['fred', 'dave'])
      wavelet = Wavelet.new(:id => "w+wavelet", :title => "Hello!",
        :participants => %w[elise dave fred karen sarah],
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

    describe "title=" do
      before :each do
        @title = "Frogosaurus Rex".freeze
        @wavelet.title = "Frogosaurus Rex"
      end
      it "should change the title attribute" do
        @wavelet.title.should == @title
      end
      it "should add an operation" do
        validate_operations(@context, [Operation::WAVELET_SET_TITLE])
        @context.operations.last.property.should == @title
      end
    end

    describe "manipulating participants" do
      before :each do
        @human_id = "human@cheese.com"
        @remote_robot_id = "remote-robot@appspot.com"
        @local_robot = robot_instance
        @wavelet = Wavelet.new(:id => "wavelet", :participants => [@human_id, @remote_robot_id, @local_robot.id])
        @context = Context.new(:wavelets => {@wavelet.id => @wavelet}, :robot => @local_robot)
        @initial_participant_ids = @wavelet.participant_ids
      end

      describe "remove_robot()" do
        it "should remove the robot from the wavelet" do
          @wavelet.remove_robot.should == @local_robot
          @wavelet.participant_ids.should == @initial_participant_ids - [@local_robot.id]
        end
        it "should add an appropriate operation to the context" do
          @wavelet.remove_robot
          validate_operations(@context, [Operation::WAVELET_REMOVE_SELF])
          @context.operations.last.property.should be_nil
        end
      end
      
      describe "add_participant()" do
        it "should add a participant to the wavelet as an id" do
          user = @wavelet.add_participant("fish@frog.com")
          user.should be_kind_of User
          @wavelet.participant_ids.should == @initial_participant_ids + ["fish@frog.com"]
          @context.users["fish@frog.com"].should be_kind_of User
        end
        it "should add a participant to the wavelet as a User" do
          user = @context.add_user(:id => "fish@frog.com")
          @wavelet.add_participant(user)
          @wavelet.participant_ids.should == @initial_participant_ids + ["fish@frog.com"]
        end
        it "should add an appropriate operation to the context" do
          @wavelet.add_participant("fish@frog.com")
          validate_operations(@context, [Operation::WAVELET_ADD_PARTICIPANT])
          @context.operations.last.property.id.should == "fish@frog.com"
        end
        it "should refuse to add a participant that is already in the wavelet" do
          @wavelet.add_participant(@human_id).should be_nil
          @wavelet.participant_ids.should == @initial_participant_ids
          validate_operations(@context, [])
        end
      end

      describe "remove_participant()" do
        it "should remove a participant from the wavelet as id" do
          user = @wavelet.remove_participant(@remote_robot_id)
          user.should be_kind_of User
          @wavelet.participant_ids.should == @initial_participant_ids - [@remote_robot_id]
        end
        it "should remove a participant from the wavelet as User" do
          @wavelet.remove_participant(@context.users[@remote_robot_id])
          @wavelet.participant_ids.should == @initial_participant_ids - [@remote_robot_id]
        end
        it "should refuse to remove a human user" do
          @wavelet.remove_participant(@human_id)
          @wavelet.participant_ids.should == @initial_participant_ids
          validate_operations(@context, [])
        end
        it "should add an appropriate operation for remote robots" do
          @wavelet.remove_participant(@remote_robot_id)
          validate_operations(@context, [Operation::WAVELET_REMOVE_PARTICIPANT])
          @context.operations.last.property.id.should == @remote_robot_id
        end
        it "should add an appropriate operation for the local robot" do
          @wavelet.remove_participant(@local_robot)
          validate_operations(@context, [Operation::WAVELET_REMOVE_SELF])
          @context.operations.last.property.should be_nil
        end
        it "should refuse to remove a participant that isn't already in the wavelet" do
          @wavelet.remove_participant("fish@appspot.com").should be_nil
          @wavelet.participant_ids.should == @initial_participant_ids
          validate_operations(@context, [])
        end
      end
    end
  end
end
