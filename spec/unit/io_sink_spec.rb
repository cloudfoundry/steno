require "spec_helper"

describe Steno::Sink::IO do
  let(:record) { { :data => "test" } }

  describe "#add_record" do
    it "should encode the record and write it to the underlying io object" do
      codec = mock("codec")
      codec.should_receive(:encode_record).with(record).and_return(record[:data])

      io = mock("io")
      io.should_receive(:write).with(record[:data])

      Steno::Sink::IO.new(io, codec).add_record(record)
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
