require "spec_helper"

describe Steno::Context::Null do
  include_context :steno_context

  let(:context) { Steno::Context::Null.new }

  it "should store no data" do
    context.data.should == {}
    context.data["foo"] = "bar"
    context.data.should == {}
  end
end

describe Steno::Context::ThreadLocal do
  include_context :steno_context

  let (:context) { Steno::Context::ThreadLocal.new }

  it "should store data local to threads" do
    b1 = Barrier.new
    b2 = Barrier.new

    t1 = Thread.new do
      context.data["thread"] = "t1"
      b1.release
      b2.wait
      context.data["thread"].should == "t1"
    end

    t2 = Thread.new do
      b1.wait
      context.data["thread"].should be_nil
      context.data["thread"] = "t2"
      b2.release
    end

    t1.join
    t2.join
  end
end

describe Steno::Context::FiberLocal do
  include_context :steno_context

  let(:context) { Steno::Context::FiberLocal.new }

  it "should store data local to fibers" do
    f2 = Fiber.new do
      context.data["fiber"].should be_nil
      context.data["fiber"] = "f2"
    end

    f1 = Fiber.new do
      context.data["fiber"] = "f1"
      f2.resume
      context.data["fiber"].should == "f1"
    end

    f1.resume
  end
end
