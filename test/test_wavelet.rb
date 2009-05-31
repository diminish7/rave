require File.join(File.dirname(__FILE__), "helper")

describe Rave::Models::Wavelet do
  
  before :all do
    @class = Rave::Models::Wavelet
  end
  
  it_should_behave_like "UniqueId"
  
  describe "initialize()" do
    
    it "should append the root suffix to the id if root == true" do
      obj = Wavelet.new
      (obj.id =~ Wavelet::ROOT_ID_REGEXP).should be_nil
      obj = Wavelet.new(:root => true)
      (obj.id =~ Wavelet::ROOT_ID_REGEXP).should_not be_nil
    end
    
  end
  
end