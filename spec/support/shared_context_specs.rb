shared_context :steno_context do
  it "should support clearing context local data" do
    context.data["test"] = "value"
    context.clear
    context.data["test"].should be_nil
  end
end
