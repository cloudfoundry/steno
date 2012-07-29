require "spec_helper"

describe Steno::Sink::Syslog do
  let(:level) do
    Steno::Logger.lookup_level(:info)
  end

  let(:record) do
    Steno::Record.new("source", level, "message")
  end

  describe "#add_record" do
    it "should append an encoded record with the correct priority" do
      identity = "test"

      syslog = mock("syslog")
      Syslog.should_receive(:open) \
            .with(identity, Syslog::LOG_PID, Syslog::LOG_USER) \
            .and_return(syslog)

      sink = Steno::Sink::Syslog.instance
      sink.open(identity)

      codec = mock("codec")
      codec.should_receive(:encode_record).with(record).and_return(record.message)
      sink.codec = codec

      syslog.should_receive(:log).with(Syslog::LOG_INFO, "%s", record.message)

      sink.add_record(record)
    end
  end

  describe "#flush" do
    it "should do nothing" do
      Steno::Sink::Syslog.instance.flush
    end
  end
end
