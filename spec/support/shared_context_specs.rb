shared_context :steno_context do
  it "should support clearing context local data" do
    context.data["test"] = "value"
    context.clear
    expect(context.data["test"]).to be_nil
  end
end
