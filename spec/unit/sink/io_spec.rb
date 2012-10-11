require "spec_helper"

describe Steno::Sink::IO do
  let(:level) do
    Steno::Logger.lookup_level(:info)
  end

  let(:record) do
    Steno::Record.new("source", level, "message")
  end

  describe ".for_file" do
    it "should return a new sink configured to append to the file at path with autosync set to true by default" do
      mock_handle = mock("file handle")

      File.should_receive(:open).with("path", "a+").and_return(mock_handle)
      mock_handle.should_receive(:sync=).with(true)

      mock_sink = mock("sink")
      Steno::Sink::IO.should_receive(:new).with(mock_handle,
                                                :max_retries => 10).
        and_return(mock_sink)

      returned = Steno::Sink::IO.for_file("path",
                                          :max_retries => 10)
      returned.should == mock_sink
    end

    it "should return a new sink configured to append to the file at path with specified options" do
      mock_handle = mock("file handle")

      File.should_receive(:open).with("path", "a+").and_return(mock_handle)
      mock_handle.should_receive(:sync=).with(false)

      mock_sink = mock("sink")
      Steno::Sink::IO.should_receive(:new).with(mock_handle,
                                                :max_retries => 10).
        and_return(mock_sink)

      returned = Steno::Sink::IO.for_file("path",
                                          :autoflush => false,
                                          :max_retries => 10)
      returned.should == mock_sink
    end
  end

  describe "#add_record" do
    it "should encode the record and write it to the underlying io object" do
      codec = mock("codec")
      codec.should_receive(:encode_record).with(record).and_return(record.message)

      io = mock("io")
      io.should_receive(:write).with(record.message)

      Steno::Sink::IO.new(io, :codec => codec).add_record(record)
    end

    it "should by default not retry on IOError" do
      codec = mock("codec")
      codec.should_receive(:encode_record).with(record).and_return(record.message)

      io = mock("io")

      io.should_receive(:write).with(record.message).ordered.and_raise(IOError)

      expect {
        Steno::Sink::IO.new(io, :codec => codec).add_record(record)
      }.to raise_error(IOError)
    end

    it "should retry not more than specified number of times on IOError" do
      codec = mock("codec")
      codec.should_receive(:encode_record).with(record).and_return(record.message)

      io = mock("io")

      io.should_receive(:write).exactly(3).times.with(record.message).ordered.
        and_raise(IOError)

      expect {
        Steno::Sink::IO.new(io, :codec => codec, :max_retries => 2).
          add_record(record)
      }.to raise_error(IOError)
    end
  end

  describe "#flush" do
    it "should call flush on the underlying io object" do
      io = mock("io")
      io.should_receive(:flush)

      Steno::Sink::IO.new(io).flush
    end
  end
end
