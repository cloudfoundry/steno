require "spec_helper"

describe Steno::Record do
  let(:record) { Steno::Record.new("test", :info, "test message") }

  it "should set the process id" do
    record.process_id.should == Process.pid
  end

  it "should set the thread id" do
    record.thread_id.should == Thread.current.object_id
  end

  it "should set the fiber id(if available)", :needs_fibers => true do
    record.fiber_id.should == Fiber.current.object_id
  end
end
