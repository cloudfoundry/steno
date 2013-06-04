require "spec_helper"

describe Steno::LogLevel do
  let(:info_level) { Steno::LogLevel.new(:info, 2) }
  let(:debug_level) { Steno::LogLevel.new(:debug, 1) }

  it "should be comparable" do
    (info_level > debug_level).should be_true
    (debug_level > info_level).should be_false
    (info_level == info_level).should be_true
  end

  describe "#to_s" do
    it "should return the name of the level" do
      info_level.to_s.should == "info"
    end
  end

  describe "#count and #inc" do
    it "increments and fetches the count" do
      expect(info_level.count).to eq 0

      info_level.inc
      expect(info_level.count).to eq 1

      info_level.inc
      expect(info_level.count).to eq 2
    end
  end
end
