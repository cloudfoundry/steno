require "yaml"

require "steno/codec"
require "steno/context"
require "steno/logger"
require "steno/sink"

module Steno
end

class Steno::Config
  class << self
    # Creates a config given a yaml file of the following form:
    #
    #     logging:
    #       level:  <info, debug, etc>
    #       file:   </path/to/logfile>
    #       syslog: <syslog name>
    #
    # @param [String] path  Path to yaml config
    # @param [Hash] overrides
    #
    # @return [Steno::Config]
    def from_file(path, overrides = {})
      h = YAML.load_file(path)
      h = h["logging"] || {}
      new(to_config_hash(h).merge(overrides))
    end

    def from_hash(hash)
      new(to_config_hash(hash))
    end

    def to_config_hash(hash)
      hash ||= {}
      hash = symbolize_keys(hash)

      level = hash[:level] || hash[:default_log_level]
      opts = {
        :sinks => [],
        :default_log_level => level.nil? ? :info : level.to_sym
      }

      if hash[:file]
        opts[:sinks] << Steno::Sink::IO.for_file(hash[:file])
      end

      if hash[:syslog]
        Steno::Sink::Syslog.instance.open(hash[:syslog])
        opts[:sinks] << Steno::Sink::Syslog.instance
      end

      opts[:sinks] << Steno::Sink::IO.new(STDOUT) if opts[:sinks].empty?
      opts
    end

    def symbolize_keys(hash)
      hash ||= {}
      symbolized = {}
      hash.each_key do |key|
        if !key.is_a? Symbol
          symbolized[key.to_sym] = hash[key]
        else
          symbolized[key] = hash[key]
        end
      end

      symbolized
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

  private_class_method :symbolize_keys
end
