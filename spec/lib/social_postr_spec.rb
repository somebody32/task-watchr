require "social_postr"

describe SocialPostr do
  it "runs through all adapters calling post task" do
    allow(SocialPostr::Adapters::Redbooth).to(
      receive(:new).and_return(adapter = double)
    )
    expect(adapter).to receive(:post_task).with("test task")
    described_class.post_task("test task")
  end

  it "rescues invalid token error" do
    allow(SocialPostr::Adapters::Redbooth).to(
      receive(:new).and_return(adapter = double)
    )
    expect(adapter).to(
      receive(:post_task)
      .and_raise(SocialPostr::Adapters::Errors::ExpiredToken)
      .ordered
    )
    token_updater = SocialPostr::TokenUpdaters::Redbooth
    expect(token_updater).to receive(:update_token)
    expect(adapter).to receive(:post_task).with("test task").ordered
    described_class.post_task("test task")
  end
end
