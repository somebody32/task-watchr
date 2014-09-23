require "social_postr"
require "sidekiq/testing"

describe SocialPostr do
  let(:adapter_settings) { { key: "some value" } }
  before do
    Sidekiq::Testing.inline!
    allow(SocialPostr::Adapters::SettingsRepository).to(
      receive(:fetch)
      .with("redbooth")
      .and_return(adapter_settings)
    )
  end

  after(:all) do
    Sidekiq::Testing.fake!
  end

  it "runs through all adapters calling post task" do
    allow(SocialPostr::Adapters::Redbooth).to(
      receive(:new).and_return(adapter = double)
    )
    expect(adapter).to receive(:post_task).with("test task")
    described_class.post_task("test task")
  end

  # I really do not like such hard mocking, so this is a candidate for a
  # fully integrational test + VCR
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
    settings_repository = SocialPostr::Adapters::SettingsRepository
    expect(token_updater).to(
      receive(:update_token)
      .with(adapter_settings)
      .and_return(new_tokens = {})
    )
    expect(settings_repository).to receive(:save).with("redbooth", new_tokens)
    expect(adapter).to receive(:post_task).with("test task").ordered
    described_class.post_task("test task")
  end
end
