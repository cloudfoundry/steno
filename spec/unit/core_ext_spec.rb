require "spec_helper"

require "steno/core_ext"

module Foo
  class Bar
  end
end

describe Module do
  describe "#logger" do
    it "should request a logger named after itself" do
      x = Foo.logger
      x.should be_a(Steno::Logger)
      x.name.should include("Foo")
    end
  end
end

describe Class do
  describe "#logger" do
    it "should request a logger named after itself" do
      x = Foo::Bar.logger
      x.should be_a(Steno::Logger)
      x.name.should include("Foo::Bar")
    end
  end
end

describe Object do
  describe "#logger" do
    it "should request a logger named after its class" do
      x = Foo::Bar.new.logger
      x.should be_a(Steno::Logger)
      x.name.should include("Foo::Bar")
    end
  end
end
