require "spec_helper"

require "steno/json_prettifier"

describe Steno::JsonPrettifier do
  let(:prettifier) { Steno::JsonPrettifier.new }
  let(:codec) { Steno::Codec::Json.new }

  describe "#prettify_line" do
    it "should return a properly formatted string" do
      record = Steno::Record.new("test", :info, "message",
                                 ["filename", "line", "method"], "test" => "data")
      encoded = codec.encode_record(record)
      prettified = prettifier.prettify_line(encoded)

      exp_regex = ['\d{4}-\d{2}-\d{2}',        # YYYY-MM-DD
                   '\d{2}:\d{2}:\d{2}\.\d{6}', # HH:MM:SS.uS
                   'test',                     # Source
                   'pid=\d+',                  # Process id
                   'tid=\w{4}',                # Thread shortid
                   'fid=\w{4}',                # Fiber shortid
                   'filename\/method:line',    # Location
                   'test=data',                # User supplied data
                   'INFO',                     # Level
                   '--',
                   'message',                  # Log message
                   ].join("\s+") + "\n"
      prettified.should match(exp_regex)
    end

    it "should raise a parse error when the json-encoded string is not a hash" do
      expect {
        prettifier.prettify_line("[1,2,3]")
      }.to raise_error(Steno::JsonPrettifier::ParseError)
    end

    it "should raise a parse error when the json-encoded string is malformed" do
      expect {
        prettifier.prettify_line("blah")
      }.to raise_error(Steno::JsonPrettifier::ParseError)
    end
  end
end
