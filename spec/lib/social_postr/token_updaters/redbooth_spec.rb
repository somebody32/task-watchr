require "social_postr/token_updaters/redbooth"

VCR.configure do |c|
  %w(
    REDBOOTH_TOKEN
    REDBOOTH_REFRESH_TOKEN
    REDBOOTH_KEY
    REDBOOTH_SECRET
  ).each do |const|
    c.filter_sensitive_data("<#{const}>") { ENV[const] }
  end
end

describe SocialPostr::TokenUpdaters::Redbooth do
  it "updates and returns a new token pair" do
    VCR.use_cassette("redbooth_token_update") do
      new_tokens = described_class.update_token(ENV['REDBOOTH_TOKEN'], ENV['REDBOOTH_REFRESH_TOKEN'])
      expect(new_tokens[:token]).not_to be_empty
      expect(new_tokens[:refresh_token]).not_to be_empty
    end
  end
end
