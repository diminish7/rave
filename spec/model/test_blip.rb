require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Blip do
  
  before :all do
    @class = Rave::Models::Blip
    @json_time_fields = [:last_modified_time]
  end
  
  it_should_behave_like "time_from_json()"
  
  describe "root?()" do
    
    it "should return true if a blip has no parent blip id" do
      blip = Blip.new
      blip.parent_blip_id.should be_nil
      blip.root?.should be_true
      blip = Blip.new(:parent_blip_id => "parent_blip")
      blip.parent_blip_id.should_not be_nil
      blip.root?.should be_false
    end
    
  end
  
  describe "has_annotation?()" do
    it "should return true if the blip has an annotation with the given name" do
      blip = Blip.new
      blip.has_annotation?("test").should be_false
      blip.annotations << Annotation.new(:name => "test")
      blip.has_annotation?("test").should be_true
    end
  end

  describe "add_child_blip()" do
    it "should add the blip to its children and to context" do
      parent = Blip.new(:id => "b+parent")
      context = Context.new(:blips => { "b+parent" => parent })
      child = Blip.new(:id => "TBD+b+child")
      parent.child_blips.should == []
      context.blips.should == { "b+parent" => parent }

      parent.add_child_blip(child)
      parent.child_blips.should == [child]
      context.blips.should == { "b+parent" => parent, "TBD+b+child" => child }
    end
  end

  describe "child_blips()" do
    it "should list the blips that are children of the blip" do
      parent = Blip.new(:id => "b+parent")
      child = Blip.new(:id => "b+child")
      context = Context.new(:blips => { "b+parent" => parent, "b+child" => child })
      parent.child_blips.should == []

      parent.add_child_blip(child)
      parent.child_blips.should == [child]
    end
  end

  describe "parent_blip()" do
    it "should return the parent of the blip, if any" do
      parent = Blip.new(:id => "b+parent")
      child = Blip.new(:id => "b+child", :parent_blip_id => "b+parent")
      context = Context.new(:blips => { "b+parent" => parent, "b+child" => child })
      parent.parent_blip.should be_nil
      child.parent_blip.should == parent
    end
  end

  describe "wavelet()" do
    it "should return the blip's wavelet" do
      blip = Blip.new(:id => "b+blip", :wavelet_id => "w+wavelet")
      wavelet = Wavelet.new(:id => "w+wavelet")
      context = Context.new(:blips => { "b+parent" => blip }, :wavelets => { "w+wavelet" => wavelet })
      blip.wavelet.should == wavelet
    end
  end

  describe "wave()" do
    it "should return the blip's wavelet" do
      blip = Blip.new(:id => "b+blip", :wave_id => "w+wave")
      wave = Wave.new(:id => "w+wave")
      context = Context.new(:blips => { "b+parent" => blip }, :waves => { "w+wave" => wave })
      blip.wave.should == wave
    end
  end

  describe "print_structure()" do
    it "should return the blip's class, id and content" do
      blip = Blip.new(:id => "b+blip", :content => "Hello!", :contributors => ['Dave'])
      blip.print_structure.should == "Blip:b+blip:Dave:Hello!\n"
    end

   it "should convert newlines to characters to prevent wrap" do
      blip = Blip.new(:id => "b+blip", :content => "Hello\nDave!", :contributors => ['Hal9000'])
      blip.print_structure.should == "Blip:b+blip:Hal9000:Hello\\nDave!\n"
    end

    it "should crop long content" do
      blip = Blip.new(:id => "b+blip", :content => 'abcdefghijklmnopqrstuvwxyz', :contributors => ['Dave'])
      blip.print_structure.should == "Blip:b+blip:Dave:abcdefghijklmnopqrstu...\n"
    end

    it "should be indented appropriately" do
      blip = Blip.new(:id => "b+blip", :content => "Hello!", :contributors => ['Dave'])
      blip.print_structure(2).should == "    Blip:b+blip:Dave:Hello!\n"
    end

    it "should show multiple contributors in order" do
      blip = Blip.new(:id => "b+blip", :content => "Hello!", :contributors => ['Claire', 'Dave', 'Sue'])
      blip.print_structure.should == "Blip:b+blip:Claire,Dave,Sue:Hello!\n"
    end

    it "should show complex series of replies to the blip" do
      blip1 = Blip.new(:id => 'b+1', :content => 'Goodbye!', :child_blip_ids => ['b+2', 'b+3', 'b+4'],
        :contributors => ['Fred', 'Dave'])
      blip2 = Blip.new(:id => 'b+2', :content => 'Cheese!', :contributors => ['Sarah'])
      blip3 = Blip.new(:id => 'b+3', :content => 'Bleh!', :contributors => ['Karen'], :child_blip_ids => ['b+5', 'b+6'])
      blip4 = Blip.new(:id => 'b+4', :content => 'Byeeee!', :contributors => ['Ken'])
      blip5 = Blip.new(:id => 'b+5', :content => 'Noooo!', :contributors => ['Sarah'])
      blip6 = Blip.new(:id => 'b+6', :content => 'Oh, shut up!', :contributors => ['Dave'])
      context = Context.new(:blips => { 'b+1' => blip1, 'b+2' => blip2, 'b+3' => blip3,
          'b+4' => blip4, 'b+5' => blip5, 'b+6' => blip6})
      
      blip1.print_structure(1).should ==<<END
  Blip:b+1:Fred,Dave:Goodbye!
    Blip:b+3:Karen:Bleh!
      Blip:b+6:Dave:Oh, shut up!
    Blip:b+5:Sarah:Noooo!

    Blip:b+4:Ken:Byeeee!
  Blip:b+2:Sarah:Cheese!
END
    end
  end
  
  describe "operations" do
  
    describe "clear()" do
      it "should clear the text" do
        blip = Blip.new(:content => "Hello wave!")
        blip.context = Context.new
        blip.content.should == "Hello wave!"
        blip.clear
        blip.content.should == ""
      end
      it "should add a delete operation to the context" do
        blip = Blip.new(:content => "Hello wave!")
        blip.context = Context.new
        blip.clear
        validate_operations(blip.context, [Operation::DOCUMENT_DELETE])
      end
    end
    
    describe "insert_text()" do
      it "should set the content of the blip" do
        blip = Blip.new(:content => "hello wave!")
        blip.context = Context.new
        blip.content.should == "hello wave!"
        blip.insert_text(" google", 5)
        blip.content.should == "hello google wave!"
      end
      it "shuold add an insert operation to the context" do
        blip = Blip.new(:content => "hello wave!")
        blip.context = Context.new
        blip.insert_text(" google", 5)
        validate_operations(blip.context, [Operation::DOCUMENT_INSERT])
      end
    end
    
    describe "set_text()" do
      it "should set the content of the blip" do
        blip = Blip.new
        blip.context = Context.new
        blip.content.should == ''
        blip.set_text "What up, blip?"
        blip.content.should == "What up, blip?"
      end
      it "should add a delete and insert operation to the context" do
        blip = Blip.new
        blip.context = Context.new
        blip.content.should == ''
        blip.set_text "What up, blip?"
        validate_operations(blip.context, [Operation::DOCUMENT_DELETE, Operation::DOCUMENT_INSERT])
      end
    end
    
    describe "delete_range()" do
      it "should delete the range of content from the blip" do
        blip = Blip.new(:content => "hello google wave!")
        blip.context = Context.new
        blip.content.should == "hello google wave!"
        blip.delete_range(5..11)
        blip.content.should == "hello wave!"
      end
      it "should add a delete operation to the context" do
        blip = Blip.new(:content => "hello google wave!")
        blip.context = Context.new
        blip.delete_range(5..11)
        validate_operations(blip.context, [Operation::DOCUMENT_DELETE])
      end
    end
    
    describe "set_text_in_range()" do
      it "should replace the range of content with the given text" do
        blip = Blip.new(:content => "hello google wave!")
        blip.context = Context.new
        blip.content.should == "hello google wave!"
        blip.set_text_in_range(6..16, "world")
        blip.content.should == "hello world!"
      end
      it "should add a delete and insert operation to the context" do
        blip = Blip.new(:content => "hello google wave!")
        blip.context = Context.new
        blip.set_text_in_range(6..16, "world")
        validate_operations(blip.context, [Operation::DOCUMENT_INSERT, Operation::DOCUMENT_DELETE])
      end
    end
    
    describe "append_text()" do
      it "should append the given text to the blip's content" do
        blip = Blip.new(:content => "hello")
        blip.context = Context.new
        blip.content.should == "hello"
        blip.append_text(" world!")
        blip.content.should == "hello world!"
      end
      it "should add an append operation to the context" do
        blip = Blip.new(:content => "hello")
        blip.context = Context.new
        blip.append_text(" world!")
        validate_operations(blip.context, [Operation::DOCUMENT_APPEND])
      end
    end

    describe "create_child_blip()" do
      before do
        @parent = Blip.new(:id => "b+parent", :wavelet_id => "w+wavelet",
          :wave_id => "w+wave")
        @context = Context.new(
          :blips => { "b+parent" => @parent },
          :wavelets => { "w+wavelet" => Wavelet.new(:id => "w+wavelet") },
          :waves => { "w+wave" => Wave.new(:id => "w+wave") }
        )
        @child = @parent.create_child_blip
      end

      it "should create a new, empty blip as a child of the parent" do
        @child.content.should == ''
        @child.should_not == @parent
        @parent.child_blips.should == [@child]
        @child.parent_blip.should == @parent
        @context.blips.should == { "b+parent" => @parent, @child.id => @child }
        @child.wave.should == @parent.wave
        @child.wavelet.should == @parent.wavelet
      end

      it "should create blips with unique ids starting with TBD" do
        @child.id.should =~ /^TBD./
        child2 = @parent.create_child_blip
        child2.id.should =~ /^TBD./
        @child.id.should_not == child2.id
      end

      it "should add an insert operation to the context" do
        validate_operations(@context, [Operation::BLIP_CREATE_CHILD])
      end
    end
  end
end
