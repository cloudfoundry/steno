require "digest/md5"
require "thread"

module Steno
end

class Steno::Record

  attr_reader :timestamp
  attr_reader :message
  attr_reader :log_level
  attr_reader :source
  attr_reader :data
  attr_reader :thread_id
  attr_reader :fiber_id
  attr_reader :process_id
  attr_reader :file
  attr_reader :lineno
  attr_reader :method

  # @param [String] source  Identifies message source.
  # @param [Symbol] log_level
  # @param [String] message
  # @param [Array]  loc        Location where the record was generated.
  #        Format is [<filename>, <lineno>, <method>].
  # @param [Hash]   data       User-supplied data
  def initialize(source, log_level, message, loc = [], data = {})
    raise "Log level must be a Symbol" unless log_level.is_a? Symbol

    @timestamp  = Time.now
    @source     = source
    @log_level  = log_level
    @message    = message.to_s
    @data       = {}.merge(data)
    @thread_id  = Thread.current.object_id
    @fiber_id   = Fiber.current.object_id
    @process_id = Process.pid

    @file, @lineno, @method = loc
  end
end
