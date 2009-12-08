require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Wave do
  before :each do
    @class = Wave
  end

  it_should_behave_like "Component to_s()"
  it_should_behave_like "Component initialize()"
  it_should_behave_like "Component id()"
  
  describe "print_structure()" do
    it "should return information about the wave" do
      wave = Wave.new(:id => "w+wave")
      Context.new(:waves => { "w+wave" => wave })
      wave.print_structure.should == "Wave:w+wave\n"
    end

    it "should return information about the wave and wavelets" do
      wavelet1 = Wavelet.new(:id => "w+1", :title => "Hello!", :participants => ['Dave'])
      wavelet2 = Wavelet.new(:id => "w+2", :title => "Goodbye!", :participants => ['Sue'])
      wave = Wave.new(:id => "w+wave", :wavelet_ids => ["w+1", "w+2"])
      Context.new(:wavelets => { "w+1" => wavelet1, "w+2" => wavelet2  }, :waves => { "w+wave" => wave })
      wave.print_structure.should ==<<END
#{wave}
  #{wavelet1}
  #{wavelet2}
END
    end
  end
end
