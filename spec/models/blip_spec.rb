require File.join(File.dirname(__FILE__), "helper")

# Test data for testing formatted text operations (set_text/append_text).
TEXT_FORMATS = [
  # format, input, operation, sent, plain
  [nil,      "Hello world!",                           Operation::DOCUMENT_APPEND,        "Hello world!",                                 "Hello world!"],
  [:plain,   "Hello world!",                           Operation::DOCUMENT_APPEND,        "Hello world!",                                 "Hello world!"],

  [:html,    "<em><strong>Hello world!</strong></em>", Operation::DOCUMENT_APPEND_MARKUP, "<em><strong>Hello world!</strong></em>",       "Hello world!"],
  [:html,    "Hello world!",                           Operation::DOCUMENT_APPEND_MARKUP, "Hello world!",                                 "Hello world!"],
  [:html,    "<em>Hello<br />world!</em>",             Operation::DOCUMENT_APPEND_MARKUP, "<em>Hello<br />world!</em>",                   "Hello\nworld!"],

  [:textile, "frog cheese",                            Operation::DOCUMENT_APPEND_MARKUP, "<p>frog cheese</p>",                           "frog cheese"],
  [:textile, "_frog_ *cheese*",                        Operation::DOCUMENT_APPEND_MARKUP, "<p><em>frog</em> <strong>cheese</strong></p>", "frog cheese" ],
  [:textile, " _frog_ *cheese*",                       Operation::DOCUMENT_APPEND_MARKUP, "<em>frog</em> <strong>cheese</strong>",        "frog cheese" ],
  [:textile, "\nfrog\ncheese\n",                         Operation::DOCUMENT_APPEND_MARKUP, "<p>frog<br />\ncheese</p>",                    "frog\ncheese" ],

]

describe Rave::Models::Blip do

  before :all do
    Rave::Models::Robot::CONFIG_FILE.sub!(/.*/, File.join(File.dirname(__FILE__), 'config.yaml'))
  end

  before :each do
    @root_blip = Blip.new(:id => "root", :child_blip_ids => ["middle"],
      :wavelet_id => "wavelet", :wave_id => "wave")
    @middle_blip = Blip.new(:id => "middle", :child_blip_ids => ["leaf"], :parent_blip_id => "root",
      :wavelet_id => "wavelet", :wave_id => "wave")
    @leaf_blip = Blip.new(:id => "leaf", :parent_blip_id => "middle",
      :wavelet_id => "wavelet", :wave_id => "wave", :content => "Bleh")

    @blip = Blip.new(:id => "blip")
    @deleted_blip = Blip.new(:id => "deleted", :state => :deleted)
    @generated_blip = Blip.new()

    @wavelet = Wavelet.new(:id => "wavelet", :root_blip_id => "root")
    @wave = Wave.new(:id => "wave", :wavelets => [@wavelet])

    @context = Context.new(
      :waves => { "wave" => @wave },
      :wavelets => {"wavelet" => @wavelet},
      :blips => { "root" => @root_blip, "middle" => @middle_blip, "leaf" => @leaf_blip,
        "blip" => @blip, "deleted" => @deleted_blip, "generated" => @generated_blip },
      :robot => ::MyRaveRobot::Robot.instance
      )

    @null_blip = Blip.new(:id => "null", :state => :null) # Not in the context.
    @json_time_fields = [:last_modified_time]
  end

  describe "initialize()" do
    it "should raise an error if given an invalid :state option" do
      lambda { Blip.new(:id => "blip", :state => :bleh) }.should raise_error(ArgumentError)
    end
  end

  it_should_behave_like "Component id()"
  it_should_behave_like "time_from_json()"

  describe "root?()" do
    it "should return true if a blip has no parent" do
      @root_blip.root?.should be_true
    end

    it "should return false if a blip has a parent" do
      @middle_blip.root?.should be_false
    end
  end

  describe "leaf?" do
    it "should return true if a blip has no children" do
      @leaf_blip.leaf?.should be_true
    end

    it "should return false if a blip has children" do
      @middle_blip.leaf?.should be_false
    end
  end

  describe "null?" do
    it "should return true if a blip is null" do
      @null_blip.null?.should be_true
    end

    it "should return false if a blip is not null" do
      @middle_blip.null?.should be_false
      @deleted_blip.null?.should be_false
    end
  end

  describe "deleted?" do
    it "should return true if a blip is deleted or null" do
      @null_blip.deleted?.should be_true
      @deleted_blip.deleted?.should be_true
    end

    it "should return false if a blip is not deleted" do
      @middle_blip.deleted?.should be_false
    end
  end

  describe "generated?" do
    it "should return true if the :creation option is :generated" do
      @generated_blip.generated?.should be_true
    end

    it "should return false if a :creation option is other than :generated" do
      @blip.generated?.should be_false
    end
  end

  describe "delete()" do
    it "should delete, but not nullify, a blip, assuming it is not a root or leaf" do
      @middle_blip.delete
      @middle_blip.deleted?.should be_true
      @middle_blip.null?.should be_false
      @context.blips["middle"].should == @middle_blip
    end

    it "should delete and destroy (nullify) a leaf blip" do
      @leaf_blip.delete
      @leaf_blip.deleted?.should be_true
      @leaf_blip.null?.should be_true
      @context.blips["leaf"].should be_nil
    end

    it "should not delete a root blip" do
      @root_blip.delete
      @root_blip.deleted?.should be_false
      @context.blips["root"].should == @root_blip
    end

    it "should cause a chain of nullification if a leaf is destroyed below a previously deleted, non-root blip" do
      @middle_blip.delete # Should delete, but not nullify.
      @leaf_blip.delete # Should destroy both blips.
      @leaf_blip.null?.should be_true
      @middle_blip.null?.should be_true
      @root_blip.null?.should be_false
    end

    it "should add a delete operation if the blip can be deleted" do
      @leaf_blip.delete
      validate_operations(@context, [Operation::BLIP_DELETE])
    end

    it "should not add a delete operation if the blip is already deleted" do
      @deleted_blip.delete
      validate_operations(@context, [])
    end
  end

  describe "add_annotation()" do
    it "should add annotations to the list" do
      blip = Blip.new(:id => "bleh")
      annotation = Annotation::Language.new("en", 5..50)
      blip.add_annotation(annotation)
      blip.annotations.should == [annotation]
    end
  end

  describe "has_annotation?()" do
    it "should return true if the blip has an annotation with the given name" do
      blip = Blip.new(:id => "bleh")
      annotation = Annotation::Language.new("en", 5..50)
      name = annotation.name
      blip.has_annotation?(name).should be_false
      blip.add_annotation(annotation)
      blip.has_annotation?(name).should be_true
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

  describe "to_s()" do
    it "should return the blip's class, id, state and content" do
      blip = Blip.new(:id => "b+blip", :content => "Hello!", :state => :normal,
        :contributors => ['dave'])
      Context.new(:blips => { "dave" => blip }, :robot => robot_instance)
      blip.to_s.should == "Blip:b+blip:dave:Hello!"
    end

    it "should return a string with the blip's state if deleted" do
      blip = Blip.new(:id => "b+blip", :state => :deleted)
      blip.to_s.should == "Blip:b+blip:<DELETED>"
    end

    it "should return a string with the blip's state if null" do
      blip = Blip.new(:id => "b+blip", :state => :null)
      blip.to_s.should == "Blip:b+blip:<NULL>"
    end

    it "should convert newlines to characters to prevent wrap" do
      blip = Blip.new(:id => "b+blip", :content => "Hello\nDave!", :contributors => ['hal9000'])
      Context.new(:blips => { blip.id => blip }, :robot => robot_instance)
      blip.to_s.should == "Blip:b+blip:hal9000:Hello\\nDave!"
    end

    it "should crop long content" do
      blip = Blip.new(:id => "b+blip", :content => 'abcdefghijklmnopqrstuvwxyz', :contributors => ['dave'])
      Context.new(:blips => { "b+blip" => blip }, :robot => robot_instance)
      blip.to_s.should == "Blip:b+blip:dave:abcdefghijklmnopqrstu..."
    end

    it "should show multiple contributors in order" do
      blip = Blip.new(:id => "b+blip", :content => "Hello!", :contributors => ['claire', 'dave', 'sue'])
      Context.new(:blips => { "b+blip" => blip }, :robot => robot_instance)
      blip.to_s.should == "Blip:b+blip:claire,dave,sue:Hello!"
    end
  end

  describe "print_structure()" do
    it "should return the blip's to_s + a newline" do
      blip = Blip.new(:id => "b+blip", :content => "Hello!", :contributors => ['dave'])
      Context.new(:blips => { "b+blip" => blip })
      blip.print_structure.should == "#{blip}\n"
    end

    it "should be indented appropriately" do
      blip = Blip.new(:id => "b+blip", :content => "Hello!", :contributors => ['dave'])
      Context.new(:blips => { "b+blip" => blip })
      blip.print_structure(2).should == "    #{blip}\n"
    end

    it "should show complex series of replies to the blip" do
      blip1 = Blip.new(:id => 'b+1', :content => 'Goodbye!', :child_blip_ids => ['b+2', 'b+3', 'b+4'],
        :contributors => ['fred', 'dave'])
      blip2 = Blip.new(:id => 'b+2', :content => 'Cheese!', :contributors => ['sarah'])
      blip3 = Blip.new(:id => 'b+3', :content => 'Bleh!', :contributors => ['karen'], :child_blip_ids => ['b+5', 'b+6'])
      blip4 = Blip.new(:id => 'b+4', :content => 'Byeeee!', :contributors => ['ken'])
      blip5 = Blip.new(:id => 'b+5', :content => 'Noooo!', :contributors => ['sarah'])
      blip6 = Blip.new(:id => 'b+6', :content => 'Oh, shut up!', :contributors => ['dave'])
      context = Context.new(:blips => { 'b+1' => blip1, 'b+2' => blip2, 'b+3' => blip3,
          'b+4' => blip4, 'b+5' => blip5, 'b+6' => blip6})

      blip1.print_structure(1).should ==<<END
  #{blip1}
    #{blip3}
      #{blip6}

    #{blip5}

    #{blip4}

  #{blip2}
END
    end
  end

  describe "operations" do

    before :each do
      @empty_blip = Blip.new(:id => "empty", :context => @context)
      @hello_wave_blip = Blip.new(:content => "Hello wave!", :id => "hello_world", :context => @context)
    end

    describe "clear()" do
      describe "on an empty blip" do
        before :each do
          @empty_blip.clear
        end
        it "should leave the text cleared" do
          @empty_blip.content.should == ""
        end
        it "should add no operations to the context" do
          validate_operations(@context, [])
        end
      end
      describe "on a blip with content" do
        before :each do
          @hello_wave_blip.clear
        end
        it "should clear the text" do
          @hello_wave_blip.content.should == ""
        end
        it "should add a delete operation to the context" do
          validate_operations(@context, [Operation::DOCUMENT_DELETE])
        end
      end
    end

    describe "insert_text()" do
      it "should set the content of the blip" do
        @hello_wave_blip.insert_text(5, " google")
        @hello_wave_blip.content.should == "Hello google wave!"
      end
      it "should add an insert operation to the context" do
        @hello_wave_blip.insert_text(5, " google")
        validate_operations(@context, [Operation::DOCUMENT_INSERT])
      end
      it "should raise error if index is outside the content string" do
        lambda { @hello_wave_blip.insert_text(12, " google") }.should raise_error(IndexError)
        lambda { @hello_wave_blip.insert_text(-13, " google") }.should raise_error(IndexError)
      end
    end

    describe "set_text()" do
      it "should raise an error if :format is unrecognised" do
        lambda { @hello_wave_blip.set_text("What up, blip?", :format => :fish)}.should raise_error(Rave::BadOptionError)
      end

      TEXT_FORMATS.each do |format, input, operation, sent, plain|
        describe "(#{input.inspect}, :format => #{format.inspect}) on blip with contents" do
          before :each do
            @hello_wave_blip.set_text(input, :format => format)
          end
          it "should set blip text, sans markup, to the input" do
            @hello_wave_blip.content.should == plain
          end
          it "should add a delete and an appropriate append operation to the context" do
            validate_operations(@context, [Operation::DOCUMENT_DELETE, operation])
          end
          it "should set the operation property to the un-filtered markup" do
            @context.operations.last.property.should == sent
          end
        end
        describe "(#{input.inspect}, :format => #{format.inspect}) on empty blip" do
          before :each do
            @empty_blip.set_text(input, :format => format)
          end
          it "should set blip text, sans markup, to the input" do
            @empty_blip.content.should == plain
          end
          it "should add an appropriate append operation to the context" do
            validate_operations(@context, [operation])
          end
          it "should set the operation property to the un-filtered markup" do
            @context.operations.last.property.should == sent
          end
        end
      end
    end

    describe "delete_range()" do
      it "should delete the inclusive range of content from the blip" do
        @hello_wave_blip.delete_range(2..6)
        @hello_wave_blip.content.should == "Heave!"
      end
      it "should add a delete operation to the context" do
        @hello_wave_blip.delete_range(2..6)
        validate_operations(@context, [Operation::DOCUMENT_DELETE])
      end
      it "should replace the exclusive range of content with the given text" do
        @hello_wave_blip.delete_range(2...7)
        @hello_wave_blip.content.should == "Heave!"
      end
      it "should raise error if range is outside the content string" do
        lambda { @hello_wave_blip.delete_range(200..201) }.should raise_error(RangeError)
      end
      it "should raise error if range is not a Range" do
        lambda { @hello_wave_blip.delete_range(5) }.should raise_error(ArgumentError)
      end
    end

    describe "set_text_in_range()" do
      it "should replace the inclusive range of content with the given text" do
        @hello_wave_blip.set_text_in_range(2..4, "xagonal")
        @hello_wave_blip.content.should == "Hexagonal wave!"
      end
      it "should add a delete and insert operation to the context" do
        @hello_wave_blip.set_text_in_range(2..4, "xagonal")
        validate_operations(@context, [Operation::DOCUMENT_INSERT, Operation::DOCUMENT_DELETE])
      end
      it "should replace the exclusive range of content with the given text" do
        @hello_wave_blip.set_text_in_range(2...5, "xagonal")
        @hello_wave_blip.content.should == "Hexagonal wave!"
      end
      it "should raise error if range is outside the content string" do
        lambda { @hello_wave_blip.set_text_in_range(200..201, "bleh") }.should raise_error(RangeError)
      end
      it "should raise error if range is not a Range" do
        lambda { @hello_wave_blip.set_text_in_range(5, "bleh") }.should raise_error(ArgumentError)
      end
    end

    describe "append_text" do
      it "should raise an error if :format is unrecognised" do
        lambda { @hello_wave_blip.append_text(" Hello world!", :format => :fish)}.should raise_error(Rave::BadOptionError)
      end

      TEXT_FORMATS.each do |format, input, operation, sent, plain|
        describe "(#{input.inspect}, :format => #{format.inspect})" do
          before :each do
            @initial_content = @hello_wave_blip.content
            @hello_wave_blip.append_text(input, :format => format)
          end

          it "should append the given text, sans markup, to the blip's content" do
            @hello_wave_blip.content.should == "#{@initial_content}#{plain}"
          end
          it "should add an #{operation} operation to the context" do
            validate_operations(@context, [operation])
          end
          it "should set the operation property to the un-filtered markup" do
            @context.operations[0].property.should == sent
          end
        end
      end
    end

    describe "create_child_blip()" do
      before :each do
        @parent = @leaf_blip
        @child = @parent.create_child_blip
      end

      it "should create a new, empty, generated blip as a child of the parent" do
        @child.content.should == ''
        @child.should_not == @parent
        @parent.child_blips.should == [@child]
        @child.parent_blip.should == @parent
        @context.blips[@child.id].should == @child
        @child.wave.should == @parent.wave
        @child.wave.should == @wave
        @child.wavelet.should == @parent.wavelet
        @child.wavelet.should == @wavelet
        @child.contributors.size.should == 1
        @child.contributors.first.id.should == "robot@appspot.com"
        @child.generated?.should be_true
      end

      it "should create blips with unique ids starting with TBD" do
        @child.id.should =~ /^TBD./
        child2 = @parent.create_child_blip
        child2.id.should =~ /^TBD./
        @child.id.should_not == child2.id
      end

      it "should add an create child operation to the context" do
        validate_operations(@context, [Operation::BLIP_CREATE_CHILD])
      end
    end

    describe "strip_html_tags()" do
      it "should strip html from a string" do
        @hello_wave_blip.instance_eval do
          strip_html_tags("<em><strong>Fish</strong> pies</em>!").should == "Fish pies!"
        end
      end
      it "should replace line-break with a newline" do
        @hello_wave_blip.instance_eval do
          strip_html_tags("<br />Fish<br/> pies!<br />").should == "\nFish\npies!\n"
        end
      end
      it "should put newline after <p>, <h?>, <div> blocks, except at end" do
        @hello_wave_blip.instance_eval do
          strip_html_tags("<p>Fish</p><div>and</div><h1>frog</h1><h2>pies!</h2>").should == "Fish\nand\nfrog\npies!"
        end
      end
      it "should compress continuous whitespace, removing it at each end" do
        @hello_wave_blip.instance_eval do
          strip_html_tags("   Fish          and\n\n\nfrog \n pies!   ").should == "Fish and frog pies!"
        end
      end
    end

    describe "append_inline_blip()" do
      before :each do
        @leaf_blip.append_inline_blip
      end

      it "should create a new element" do
        @leaf_blip.elements.size.should == 1
        element = @leaf_blip.elements.values[0]
        element.kind_of? Element::InlineBlip
      end

      it "should create a new blip inside the new element" do
        blip = @leaf_blip.elements.values[0].blip
        blip.parent_blip.should be_nil
        blip.child_blips.should == []
        blip.wave.should == @leaf_blip.wave
        blip.wavelet.should == @leaf_blip.wavelet
      end

      it "should create an appropriate operation" do
        validate_operations(@context, [Operation::DOCUMENT_INLINE_BLIP_APPEND])
        @context.operations[0].index.should == -1
        @context.operations[0].property.should == @leaf_blip.elements.values[0].blip
      end
    end

    describe "delete_inline_blip()" do
      before :each do
        @leaf_blip.append_inline_blip
        @inline_blip = @leaf_blip.elements.values[0].blip
      end

      it "should raise error if the blip is not an inline blip of this blip" do
        lambda { @leaf_blip.delete_inline_blip("frogspawn") }.should raise_error(RuntimeError)
      end

      it "should delete the element" do
        @leaf_blip.delete_inline_blip(@inline_blip)
        @leaf_blip.elements.size.should == 0
      end

      it "should create an appropriate operation" do
        @leaf_blip.delete_inline_blip(@inline_blip)
        validate_operations(@context, [Operation::DOCUMENT_INLINE_BLIP_APPEND, Operation::DOCUMENT_INLINE_BLIP_DELETE])
      end
    end

    describe "insert_inline_blip()" do
      before :each do
        @insert_at = 2
        @leaf_blip.insert_inline_blip(@insert_at)
      end

      it "should create a new element" do
        @leaf_blip.elements.size.should == 1
        element = @leaf_blip.elements.values[0]
        element.kind_of? Element::InlineBlip
      end

      it "should create a new blip inside the new element" do
        blip = @leaf_blip.elements.values[0].blip
        blip.parent_blip.should be_nil
        blip.child_blips.should == []
        blip.wave.should == @leaf_blip.wave
        blip.wavelet.should == @leaf_blip.wavelet
      end

      it "should create an appropriate operation" do
        validate_operations(@context, [Operation::DOCUMENT_INLINE_BLIP_INSERT])
        @context.operations[0].index.should == @insert_at
        @context.operations[0].property.should == @leaf_blip.elements.values[0].blip
      end
    end

    describe "append_element()" do
      it "should work" do
        pending
      end
    end

    describe "insert_element()" do
      it "should work" do
        pending
      end
    end

    describe "delete_element()" do
      it "should work" do
        pending
      end
    end
  end
end
