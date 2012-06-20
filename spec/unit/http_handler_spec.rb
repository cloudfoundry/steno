require "spec_helper"

require "steno/http_handler"

describe Steno::HttpHandler do
  include Rack::Test::Methods

  let(:config) { Steno::Config.new }

  before :each do
    Steno.init(config)
  end

  def app
    Steno::HttpHandler
  end

  describe "GET /loggers/levels" do
    it "returns a hash of logger name to level" do
      get "/loggers/levels"
      json_body.should == {}

      foo = Steno.logger("foo")
      foo.level = :debug

      bar = Steno.logger("bar")
      bar.level = :info

      get "/loggers/levels"
      json_body.should == { "foo" => "debug", "bar" => "info" }
    end
  end

  describe "PUT /loggers/levels" do
    it "returns an error on missing parameters" do
      put "/loggers/levels"
      last_response.status.should == 400
      json_body["error"].should match(/Missing query parameters/)

      put "/loggers/levels", :regexp => "hi"
      last_response.status.should == 400
      json_body["error"].should match(/Missing query parameters/)

      put "/loggers/levels", :level => "debug"
      last_response.status.should == 400
      json_body["error"].should match(/Missing query parameters/)
    end

    it "returns an error on invalid log levels" do
      put "/loggers/levels", :regexp => "hi", :level => "foobar"
      last_response.status.should == 400
      json_body["error"].should match(/Unknown level/)
    end

    it "updates log levels for loggers whose name matches the regexp" do
      foo = Steno.logger("foo")
      foo.level = :debug

      bar = Steno.logger("bar")
      bar.level = :warn

      put "/loggers/levels", :regexp => "f", :level => "error"
      last_response.status.should == 200

      foo.level.should == :error
      bar.level.should == :warn
    end
  end

  def json_body
    Yajl::Parser.parse(last_response.body)
  end
end
