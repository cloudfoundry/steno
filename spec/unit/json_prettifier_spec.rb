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

    it "should always use the largest src len to determine src column width" do
      test_srcs = [
        'a' * (Steno::JsonPrettifier::MIN_COL_WIDTH - 3),
        'a' * (Steno::JsonPrettifier::MIN_COL_WIDTH - 1),
        'a' * (Steno::JsonPrettifier::MIN_COL_WIDTH),
        'a' * (Steno::JsonPrettifier::MIN_COL_WIDTH + 1),
        'a' * (Steno::JsonPrettifier::MIN_COL_WIDTH - 3),
        'a' * (Steno::JsonPrettifier::MIN_COL_WIDTH + 3),
        'a' * (Steno::JsonPrettifier::MIN_COL_WIDTH - 2),
        'a' * (Steno::JsonPrettifier::MIN_COL_WIDTH + 2)
      ]

      regex = ['\d{4}-\d{2}-\d{2}',        # YYYY-MM-DD
               '\d{2}:\d{2}:\d{2}\.\d{6}', # HH:MM:SS.uS
               '([a-zA-Z0-9\ ]+)',         # Source (to be captured)
               'pid=\d+',                  # Process id
               '.+'                        # Everything else
      ].join("\s") + "\n"

      max_src_len = Steno::JsonPrettifier::MIN_COL_WIDTH
      test_srcs.each do |src|
        record = Steno::Record.new(src,
                                   :info,
                                   "message",
                                   ["filename", "line", "method"],
                                   "test" => "data")

        encoded = codec.encode_record(record)
        prettified = prettifier.prettify_line(encoded)
        src_col = prettified.match(regex)[1]

        max_src_len = [max_src_len, src.length].max
        src_col.length.should == max_src_len
      end
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

    it "should work with a nil data field" do
      line = prettifier.prettify_line(%@{"data":null}@)
      line.should include(" - ")
    end
  end
end
