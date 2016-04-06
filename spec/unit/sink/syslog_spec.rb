require "spec_helper"
unless Steno::Sink::WINDOWS
  describe Steno::Sink::Syslog do
    let(:level) do
      Steno::Logger.lookup_level(:info)
    end

    let(:record) do
      Steno::Record.new("source", level.name, "message")
    end

    let(:record_with_big_message) do
      Steno::Record.new("source", level.name,
        "a" * (Steno::Sink::Syslog::MAX_MESSAGE_SIZE + 1))
    end

    describe "#add_record" do
      after do
        Syslog::Logger.syslog = nil
      end

      it "should append an encoded record with the correct priority" do
        identity = "test"

        syslog = double("syslog", facility: nil)
        expect(Syslog).to receive(:open).and_return(syslog)

        sink = Steno::Sink::Syslog.instance
        sink.open(identity)

        codec = double("codec")
        expect(codec).to receive(:encode_record).with(record).and_return(record.message)
        sink.codec = codec

        expect(syslog).to receive(:log).with(Syslog::LOG_INFO, "%s", record.message)

        sink.add_record(record)
      end

      it "should truncate the record message if its greater than than allowed size" do
        identity = "test"

        syslog = double("syslog", facility: nil)
        expect(Syslog).to receive(:open).and_return(syslog)

        sink = Steno::Sink::Syslog.instance
        sink.open(identity)

        truncated = record_with_big_message.message.
            slice(0..(Steno::Sink::Syslog::MAX_MESSAGE_SIZE) - 4)
        truncated << Steno::Sink::Syslog::TRUNCATE_POSTFIX
        codec = double("codec")
        expect(codec).to receive(:encode_record) do |*args|
          expect(args.size).to eq(1)
          expect(args[0].message).to eq(truncated)
          expect(args[0].message.size).to be <= Steno::Sink::Syslog::MAX_MESSAGE_SIZE

          next args[0].message
        end

        sink.codec = codec

        expect(syslog).to receive(:log).with(Syslog::LOG_INFO, "%s", truncated)

        sink.add_record(record_with_big_message)
      end
    end

    describe "#flush" do
      it "should do nothing" do
        Steno::Sink::Syslog.instance.flush
      end
    end
  end
end
