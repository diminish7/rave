require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Blip do
  
  before :all do
    @class = Rave::Models::Blip
  end
  
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
        blip.content.should be_nil
        blip.set_text "What up, blip?"
        blip.content.should == "What up, blip?"
      end
      it "should add a delete and insert operation to the context" do
        blip = Blip.new
        blip.context = Context.new
        blip.content.should be_nil
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
        validate_operations(blip.context, [Operation::DOCUMENT_DELETE, Operation::DOCUMENT_INSERT])
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
    
  end
  
end