describe Steno::TaggedLogger do
  let(:sink) { NullSink.new }
  let(:logger) { Steno::Logger.new("test", [sink]) }
  let(:user_data) { { "foo" => "bar" } }
  let(:tagged_logger) { Steno::TaggedLogger.new(logger, user_data) }

  it "should add any user data to each log record" do
    tagged_logger.info("testing", "test" => "data")
    sink.records.size.should == 1
    sink.records[0].data.should == user_data.merge("test" => "data")

    tagged_logger.log_exception(RuntimeError.new("hi"))
    sink.records.size.should == 2
    sink.records[1].data.should == user_data.merge(:backtrace => nil)
  end

  it "should forward missing methods to the proxied logger" do
    tagged_logger.level.should == :info
    tagged_logger.level = :warn

    logger.level.should == :warn

    tagged_logger.level_active?(:info).should be_false
  end

  describe "#tag" do
    it "should return a new tagged logger with merged user-data" do
      tl = tagged_logger.tag("bar" => "baz")
      tl.proxied_logger.should == logger
      tl.user_data.should == user_data.merge("bar" => "baz")
    end
  end
end
