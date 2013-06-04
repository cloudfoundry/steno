module Steno
end

class Steno::LogLevel
  include Comparable

  attr_reader :name
  attr_reader :priority

  # @param [String]  name      "info", "debug", etc.
  # @param [Integer] priority  "info" > "debug", etc.
  def initialize(name, priority)
    @name = name
    @priority = priority
    @mutex = Mutex.new
    @count = 0
  end

  def to_s
    @name.to_s
  end

  def <=>(other)
    @priority <=> other.priority
  end

  def count
    @mutex.synchronize { @count }
  end

  def inc
    @mutex.synchronize { @count += 1 }
  end
end
