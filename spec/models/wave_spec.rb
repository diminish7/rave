require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Wave do
  it_should_behave_like "Component to_s()"
  it_should_behave_like "Component id()"

  describe "root_wavelet()" do
    it "should return nil if there are no wavelets" do
      wave = Wave.new(:id => 'wave')
      Context.new(:waves => {wave.id => wave})
      wave.root_wavelet.should be_nil
    end

    it "should return nil if no wavelet ids end in the root suffix" do
      foo = Wavelet.new(:id => "foo")
      bar =  Wavelet.new(:id => "bar")
      wavelets = { foo.id => foo, bar.id => bar }
      wave = Wave.new(:id => 'wave', :wavelet_ids => wavelets.keys)
      Context.new(:waves => {wave.id => wave}, :wavelets => wavelets)
      wave.root_wavelet.should be_nil
    end

    it "should return a wavelet if its id ends in the root suffix" do
      root = Wavelet.new(:id => "bar" + Wavelet::ROOT_ID_SUFFIX)
      wavelets = {"foo" => Wavelet.new(:id => "foo"), root.id => root}
      wave = Wave.new(:id => 'wave', :wavelet_ids => wavelets.keys)
      Context.new(:waves => {wave.id => wave}, :wavelets => wavelets )
      wave.root_wavelet.should == root
    end
  end

  describe "wavelets" do
    it "should return the wavelets corresponding to the :wavelets option" do
      root = Wavelet.new(:id => "bar" + Wavelet::ROOT_ID_SUFFIX)
      wavelets = {"foo" => Wavelet.new(:id => "foo"), root.id => root}.freeze
      wave = Wave.new(:id => 'wave', :wavelet_ids => wavelets.keys)
      Context.new(:waves => {wave.id => wave}, :wavelets => wavelets )
      wave.wavelets.should == wavelets.values
    end
  end

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
