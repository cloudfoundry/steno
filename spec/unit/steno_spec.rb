require "spec_helper"

describe Steno do
  let(:config) { Steno::Config.new }

  before :each do
    Steno.init(config)
  end

  describe "#logger" do
    it "should return a new Steno::Logger instance" do
      logger = Steno.logger("test")
      logger.should_not be_nil
      logger.name.should == "test"
    end

    it "should memoize loggers by name" do
      logger1 = Steno.logger("test")
      logger2 = Steno.logger("test")

      logger1.object_id.should == logger2.object_id
    end
  end

  describe "#set_logger_regexp" do
    it "should modify the levels of existing loggers that match the regex" do
      logger = Steno.logger("test")

      logger.level.should == :info

      Steno.set_logger_regexp(/te/, :debug)

      logger.level.should == :debug
    end

    it "should modify the levels of new loggers after a regexp has been set" do
      Steno.set_logger_regexp(/te/, :debug)

      Steno.logger("te").level.should == :debug
    end

    it "should reset the levels of previously matching loggers when changed" do
      Steno.set_logger_regexp(/foo/, :debug)

      logger = Steno.logger("foo")
      logger.level.should == :debug

      Steno.set_logger_regexp(/bar/, :debug)

      logger.level.should == :info
    end
  end

  describe "#clear_logger_regexp" do
    it "should reset any loggers matching the existing regexp" do
      Steno.set_logger_regexp(/te/, :debug)

      logger = Steno.logger("test")
      logger.level.should == :debug

      Steno.clear_logger_regexp

      logger.level.should == :info
      Steno.logger_regexp.should be_nil
    end
  end

  describe "#logger_level_snapshot" do
    it "should return a hash mapping logger name to level" do
      loggers = []

      expected = {
        "foo" => :debug,
        "bar" => :warn,
      }

      expected.each do |name, level|
        # Prevent GC
        loggers << Steno.logger(name)
        loggers.last.level = level
      end

      Steno.logger_level_snapshot.should == expected
    end
  end
end
