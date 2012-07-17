require "spec_helper"

module Foo
  class Bar
  end
end

describe Class do
  describe "#logger" do
    it "should request a logger named after the class" do
      Steno.should_receive(:logger).with("Foo::Bar")
      x = Foo::Bar.logger
    end
  end
end
