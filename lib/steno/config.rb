require "yaml"

require "steno/codec"
require "steno/context"
require "steno/logger"
require "steno/sink"

module Steno
end

class Steno::Config
  class << self
    def from_file(path, overrides = {})
      h = YAML.load_file(path)

      opts = {
        :sinks => [],
        :default_log_level => h["level"].to_sym,
      }

      if h["file"]
        opts[:sinks] << Steno::Sink::IO.for_file(h["file"])
      end

      if h["syslog"]
        Steno::Sink::Syslog.instance.open(h["syslog"])
        opts[:sinks] << Steno::Sink::Syslog.instance
      end

      if opts[:sinks].empty?
        opts[:sinks] << Steno::Sink::IO.new(STDOUT)
      end

      new(opts.merge(overrides))
    end
  end

  attr_reader :sinks
  attr_reader :codec
  attr_reader :context
  attr_reader :default_log_level

  def initialize(opts = {})
    @sinks             = opts[:sinks] || []
    @codec             = opts[:codec] || Steno::Codec::Json.new
    @context           = opts[:context] ||Steno::Context::Null.new

    @sinks.each { |sink| sink.codec = @codec }

    if opts[:default_log_level]
      @default_log_level = opts[:default_log_level].to_sym
    else
      @default_log_level = :info
    end
  end
end
