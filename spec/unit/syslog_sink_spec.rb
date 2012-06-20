require "spec_helper"

describe Steno::Sink::Syslog do
  describe "#add_record" do
    it "should append an encoded record with the correct priority" do
      identity = "test"

      syslog = mock("syslog")
      Syslog.should_receive(:open) \
            .with(identity, Syslog::LOG_PID, Syslog::LOG_USER) \
            .and_return(syslog)

      sink = Steno::Sink::Syslog.instance
      sink.open(identity)

      record = Steno::Record.new("test", :info, "hello")

      codec = mock("codec")
      codec.should_receive(:encode_record).with(record).and_return("test")
      sink.codec = codec

      syslog.should_receive(:log).with(Syslog::LOG_INFO, "%s", "test")

      sink.add_record(record)
    end
  end
end
