$:.unshift File.dirname(File.dirname(__FILE__))
require 'robot'

describe SpoonerTest::Robot do
  before :each do
    @robot = described_class.instance
  end

  it "should be parsed correcty" do
    # Just allow the robot to be created.
  end
end

