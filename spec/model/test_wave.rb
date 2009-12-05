require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Wave do
  describe "print_structure()" do
    it "should return information about the wave" do
      wave = Wave.new(:id => "w+wave")
      context = Context.new(:waves => { "w+wave" => wave })
      wave.print_structure.should == "Wave:w+wave\n"
    end

    it "should return information about the wave and wavelets" do
      wavelet1 = Wavelet.new(:id => "w+1", :title => "Hello!", :participants => ['Dave'])
      wavelet2 = Wavelet.new(:id => "w+2", :title => "Goodbye!", :participants => ['Sue'])
      wave = Wave.new(:id => "w+wave", :wavelet_ids => ["w+1", "w+2"])
      context = Context.new(:wavelets => { "w+1" => wavelet1, "w+2" => wavelet2  }, :waves => { "w+wave" => wave })
      wave.print_structure.should ==<<END
Wave:w+wave
  Wavelet:w+1:Dave:Hello!
  Wavelet:w+2:Sue:Goodbye!
END
    end
  end
end