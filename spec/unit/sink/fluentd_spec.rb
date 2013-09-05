require "spec_helper"

describe Steno::Sink::IO do
  let(:level) do
    Steno::Logger.lookup_level(:info)
  end

  let(:record) do
    Steno::Record.new("source", level.name, "message")
  end

  describe "#initialize" do
    it "should initialize FluentLogger with the default option" do
      Fluent::Logger::FluentLogger.should_receive(:new).with("steno", {
        :host => "127.0.0.1",
        :port => 24224,
        :buffer_limit => Fluent::Logger::FluentLogger::BUFFER_LIMIT,
        }).and_return()
      sink = Steno::Sink::Fluentd.new()
    end

    it "should initialize FliuentLogger with override options" do
      Fluent::Logger::FluentLogger.should_receive(:new).with("vcap", {
        :host => "localhost",
        :port => 8080,
        :buffer_limit => 1024,
        }).and_return()
      sink = Steno::Sink::Fluentd.new({
        :tag_prefix => "vcap",
        :host => "localhost",
        :port => 8080,
        :buffer_limit => 1024
        })
    end
  end

  describe "#add_record" do
    it "should post an record with the correct tag" do
      fluentd = double("fluentd")
      Fluent::Logger::FluentLogger.should_receive(:new).and_return(fluentd)
      fluentd.should_receive(:post).with("source", record)
      sink = Steno::Sink::Fluentd.new()
      sink.add_record(record)
    end
  end
end