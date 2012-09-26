require "spec_helper"

describe Steno::Record do
  let(:message) { Array("test message") }
  let(:record) { Steno::Record.new("test", :info, message) }

  it "should set the process id" do
    record.process_id.should == Process.pid
  end

  it "should set the thread id" do
    record.thread_id.should == Thread.current.object_id
  end

  it "should set the fiber id(if available)", :needs_fibers => true do
    record.fiber_id.should == Fiber.current.object_id
  end

  it "should set the source" do
    record.source.should == "test"
  end

  it "should stringify the message" do
    record.message.should be_a(String)
  end

  it "should use a UTC timestamp" do
    record.timestamp.to_f.should be_within(0.1).of(Time.now.utc.to_f)
  end
end
