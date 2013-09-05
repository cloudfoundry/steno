require "spec_helper"

describe Steno::Logger do
  let(:logger) { Steno::Logger.new("test", []) }

  it "should provide #level, #levelf, and #level? methods for each log level" do
    Steno::Logger::LEVELS.each do |name, _|
      [name, name.to_s + "f", name.to_s + "?"].each do |meth|
        logger.respond_to?(meth).should be_true
      end
    end
  end

  describe "#level_active?" do
    it "should return a boolean indicating if the level is enabled" do
      logger.level_active?(:error).should be_true
      logger.level_active?(:info).should be_true
      logger.level_active?(:debug).should be_false
    end
  end

  describe "#<level>?" do
    it "should return a boolean indiciating if <level> is enabled" do
      logger.error?.should be_true
      logger.info?.should be_true
      logger.debug?.should be_false
    end
  end

  describe "#level" do
    it "should return the name of the currently active level" do
      logger.level.should == :info
    end
  end

  describe "#level=" do
    it "should allow the level to be changed" do
      logger.level = :warn
      logger.level.should == :warn
      logger.level_active?(:info).should be_false
      logger.level_active?(:warn).should be_true
    end
  end

  describe "#log" do
    it "should not forward any messages for levels that are inactive" do
      sink = double("sink")
      sink.should_not_receive(:add_record)

      my_logger = Steno::Logger.new("test", [sink])

      my_logger.debug("test")
    end

    it "should forward messages for levels that are active" do
      sink = double("sink")
      sink.should_receive(:add_record).with(any_args())

      my_logger = Steno::Logger.new("test", [sink])

      my_logger.warn("test")
    end

    it "should not invoke a supplied block if the level is inactive" do
      invoked = false
      logger.debug { invoked = true }
      invoked.should be_false
    end

    it "should invoke a supplied block if the level is active" do
      invoked = false
      logger.warn { invoked = true }
      invoked.should be_true
    end

    it "creates a record with the proper level" do
      sink = double("sink")
      Steno::Record.should_receive(:new).with("test", :warn, "message", anything, anything).and_call_original
      sink.stub(:add_record)

      my_logger = Steno::Logger.new("test", [sink])

      my_logger.warn("message")
    end
  end

  describe "#logf" do
    it "should format messages according to the supplied format string" do
      logger.should_receive(:log).with(:debug, "test 1 2.20")
      logger.debugf("test %d %0.2f", 1, 2.2)
    end
  end

  describe "#tag" do
    it "should return a tagged logger" do
      tagged_logger = logger.tag("foo" => "bar")
      tagged_logger.should_not be_nil
      tagged_logger.user_data.should == { "foo" => "bar" }
    end
  end
end
