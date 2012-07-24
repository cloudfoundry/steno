require "spec_helper"

module Foo
  class Bar
  end
end

describe Class do
  describe "#logger" do
    it "should request a logger named after the class" do
      expect do
        Foo::Bar.logger
      end.to raise_error(/undefined/)

      require "steno/core_ext"
      x = Foo::Bar.logger
      x.should_not be_nil
    end
  end
end
