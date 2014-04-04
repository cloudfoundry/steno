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

    it "shouldn't use readable dates by default" do
      codec.iso8601_timestamps?.should == false
    end

    context "when iso8601_timestamps is set" do
      let(:codec) { Steno::Codec::Json.new( :iso8601_timestamps => true ) }

      it "should encode timestamps as UTC-formatted strings" do
        allow(record).to receive(:timestamp).and_return 1396473763.811278 # 2014-04-02 22:22:43 +01:00
        parsed = Yajl::Parser.parse(codec.encode_record(record))

        parsed["timestamp"].class.should == String
        parsed["timestamp"].should eq("2014-04-02T21:22:43.811278Z")
      end

      it "should surface the property in a getter" do
        codec.iso8601_timestamps?.should == true
      end
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
