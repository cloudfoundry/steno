require "spec_helper"

describe Steno::Codec::Json do
  let(:codec) { Steno::Codec::Json.new }
  let(:record) { make_record(:data => { "user" => "data" }) }

  describe "#encode_record" do
    it "should encode records as json hashes" do
      parsed = Yajl::Parser.parse(codec.encode_record(record))
      parsed.class.should == Hash
    end

    it "should encode the timestamp as a float" do
      parsed = Yajl::Parser.parse(codec.encode_record(record))
      parsed["timestamp"].class.should == Float
    end

    it "should escape newlines" do
      rec = make_record(:message => "newline\ntest")
      codec.encode_record(rec).should match(/newline\\ntest/)
    end

    it "should escape carriage returns" do
      rec = make_record(:message => "newline\rtest")
      codec.encode_record(rec).should match(/newline\\rtest/)
    end

    it "should allow messages with valid encodings to pass through untouched" do
      msg = "HI\u2600"
      rec = make_record(:message => msg)
      codec.encode_record(rec).should match(/#{msg}/)
    end

    it "should treat messages with invalid encodings as binary data" do
      msg = "HI\u2026".force_encoding("US-ASCII")
      rec = make_record(:message => msg)
      codec.encode_record(rec).should match(/HI\\\\xe2\\\\x80\\\\xa6/)
    end
  end

  def make_record(opts = {})
    Steno::Record.new(opts[:source]  || "my_source",
                      opts[:level]   || :debug,
                      opts[:message] || "test message",
                      nil,
                      opts[:data]    || {})
  end
end
