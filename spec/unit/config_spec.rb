require "fileutils"
require "yaml"

require "spec_helper"

describe Steno::Config do
  describe ".from_hash" do
    before :each do
      @log_path = "some_file"

      @mock_sink_file = mock("sink")
      @mock_sink_file.stub(:codec=)
      Steno::Sink::IO.should_receive(:for_file).with(@log_path, :max_retries => 1)
        .and_return(@mock_sink_file)

      @mock_sink_syslog = mock("sink")
      @mock_sink_syslog.stub(:codec=)
      @mock_sink_syslog.should_receive(:open).with("test")
      Steno::Sink::Syslog.should_receive(:instance).twice()
        .and_return(@mock_sink_syslog)
    end

    after :each do
      @config = Steno::Config.from_hash(@hash)

      @config.default_log_level.should == :debug2
      @config.context.should.class == Steno::Context::Null
      @config.codec.should.class == Steno::Codec::Json

      @config.sinks.size.should == 2
      @config.sinks.should =~ [@mock_sink_file, @mock_sink_syslog]
    end

    it "should work for symbolized keys" do
      @hash = {
        :file => @log_path,
        :level => "debug2",
        :default_log_level => "warn",
        :syslog => "test"
      }
    end

    it "should work for non-symbolized keys" do
      @hash = {
        "file" => @log_path,
        "level" => "debug2",
        "default_log_level" => "warn",
        "syslog" => "test"
      }
    end
  end

  describe ".from_file" do
    before :each do
      @tmpdir = Dir.mktmpdir
      @config_path = File.join(@tmpdir, "config.yml")
      @log_path = File.join(@tmpdir, "test.log")
    end

    after :each do
      FileUtils.rm_rf(@tmpdir)
    end

    it "should return Steno::Config instance with sane defaults" do
      write_config(@config_path, {})

      config = Steno::Config.from_file(@config_path)

      config.sinks.size.should == 1
      config.sinks[0].class.should == Steno::Sink::IO

      config.default_log_level.should == :info

      config.context.should.class == Steno::Context::Null

      config.codec.should.class == Steno::Codec::Json
    end

    it "should set the default_log_level if a key with the same name is supplied" do
      write_config(@config_path, { "level" => "debug2" })
      Steno::Config.from_file(@config_path).default_log_level.should == :debug2

      write_config(@config_path, { "default_log_level" => "debug2" })
      Steno::Config.from_file(@config_path).default_log_level.should == :debug2
    end

    it "should read the 'level' key if both default_log_level and level are spscified" do
      write_config(@config_path, { "level" => "debug2", "default_log_level" => "warn" })
      Steno::Config.from_file(@config_path).default_log_level.should == :debug2
    end

    it "should add a file sink if the 'file' key is specified" do
      write_config(@config_path, { "file" => @log_path })
      mock_sink = mock("sink")
      mock_sink.stub(:codec=)

      Steno::Sink::IO.should_receive(:for_file).
        with(@log_path, :max_retries => 1).and_return(mock_sink)
      config = Steno::Config.from_file(@config_path)
      config.sinks.size.should == 1
      config.sinks[0].should == mock_sink
    end

    it "should add a syslog sink if the 'syslog' key is specified" do
      write_config(@config_path, { "syslog" => "test" })
      mock_sink = mock("sink")
      mock_sink.should_receive(:open).with("test")
      mock_sink.stub(:codec=)

      Steno::Sink::Syslog.should_receive(:instance).twice().and_return(mock_sink)

      config = Steno::Config.from_file(@config_path)
      config.sinks.size.should == 1
      config.sinks[0].should == mock_sink
    end

    it "should add an io sink to stdout if no sinks are explicitly specified in the config file" do
      write_config(@config_path, {})
      mock_sink = mock("sink")
      mock_sink.stub(:codec=)

      Steno::Sink::IO.should_receive(:new).with(STDOUT, :max_retries => 1).
          and_return(mock_sink)

      config = Steno::Config.from_file(@config_path)
      config.sinks.size.should == 1
      config.sinks[0].should == mock_sink
    end

    it "should merge supplied overrides with the file based config" do
      write_config(@config_path, { "default_log_level" => "debug" })

      context = Steno::Context::ThreadLocal.new
      config = Steno::Config.from_file(@config_path,
                                       :default_log_level => "warn",
                                       :context => context)
      config.context.should == context
      config.default_log_level.should == :warn
    end
  end

  def write_config(path, config)
    File.open(path, "w+") do |f|
      f.write(YAML.dump({ "logging" => config }))
    end
  end
end
