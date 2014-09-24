require "rails_helper"

describe FetchrSocialSettings do
  let(:user_settings) do
    {
      client_key: "test key",
      client_secret: "test secret"
    }
  end

  it "saves and reads settings" do
    DatabaseCleaner.cleaning do
      expect(described_class.fetch).to eql({})
      settings = described_class.new(user_settings)
      expect(settings.save).to eql(true)
      expect(described_class.fetch).to include(user_settings)
    end
  end

  it "mixes app key and secret to settings" do
    DatabaseCleaner.cleaning do
      described_class.new(user_settings).save
      expect(described_class.fetch).to include(
        app_key: ENV["TWITTER_KEY"],
        app_secret: ENV["TWITTER_SECRET"]
      )
    end
  end

  it "validates right settings values" do
    settings = described_class.new(client_key: "test")
    expect(settings.save).to eql(false)
  end
end
