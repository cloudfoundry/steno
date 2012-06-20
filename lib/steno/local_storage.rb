require "fiber"
require "thread"

class Fiber
  def __steno_locals__
    @__steno_locals__ ||= {}
  end
end

module Steno::LocalStorage
  class << self
    def thread_locals
      Thread.current["__steno_locals__"] ||= {}
    end

    def fiber_locals
      Fiber.current.__steno_locals__
    end
  end
end
