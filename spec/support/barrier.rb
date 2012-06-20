require "thread"

class Barrier
  def initialize
    @lock = Mutex.new
    @cvar = ConditionVariable.new
    @done = false
  end

  def release
    @lock.synchronize do
      @done = true
      @cvar.broadcast
    end
  end

  def wait
    @lock.synchronize do
      @cvar.wait(@lock) if !@done
    end
  end
end
