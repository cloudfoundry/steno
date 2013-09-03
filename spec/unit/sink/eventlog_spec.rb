require "spec_helper"
if Steno::Sink::WINDOWS
  describe Steno::Sink::Eventlog do
    let(:level) do
      Steno::Logger.lookup_level(:info)
    end

    let(:record) do
      Steno::Record.new("source", level.name, "message")
    end

    describe "#add_record" do

      it "should append an encoded record with the correct priority" do
        eventlog = mock("Win32::EventLog")
        Win32::EventLog.should_receive(:open) \
            .with('Application') \
            .and_return(eventlog)

        sink = Steno::Sink::Eventlog.instance
        sink.open

        codec = mock("codec")
        codec.should_receive(:encode_record).with(record).and_return(record.message)
        sink.codec = codec

        eventlog.should_receive(:report_event).with(:source      => "CloudFoundry",
                                                    :event_type  => Win32::EventLog::INFO,
                                                    :data        => record.message)

        sink.add_record(record)
      end
    end

    describe "#flush" do
      it "should do nothing" do
        Steno::Sink::Eventlog.instance.flush
      end
    end
  end
end
