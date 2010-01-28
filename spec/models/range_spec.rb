require File.join(File.dirname(__FILE__), "helper")

describe Range do
  describe "to_rave_hash()" do
    it "should convert 0..55 to a hash" do
      (0..55).to_rave_hash.should == { "javaClass" => "com.google.wave.api.Range", "start" => 0, "end" => 55 }
    end

    it "should convert 1...4 to a hash" do
      (1...4).to_rave_hash.should == { "javaClass"  => "com.google.wave.api.Range", "start" => 1, "end" => 3 }
    end
  end
end