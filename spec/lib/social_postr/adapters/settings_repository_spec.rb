require "social_postr/adapters/settings_repository"
require "database_cleaner"

describe SocialPostr::Adapters::SettingsRepository do
  let(:adapter_name) { :redbooth }
  let(:settings) do
    {
      "key" => "test key",
      "secret" => "test secret",
      "token" => "some token"
    }
  end

  it "stores settings for an adapter" do
    DatabaseCleaner.cleaning do
      expect(described_class.fetch(adapter_name)).to eql({})
      described_class.save(adapter_name, settings)
      expect(described_class.fetch(adapter_name)).to eql(settings)
    end
  end

  it "partially update settings for an adapter" do
    DatabaseCleaner.cleaning do
      updated_part = { "token" => "new token" }
      described_class.save(adapter_name, settings)
      described_class.save(adapter_name, updated_part)
      expect(described_class.fetch(adapter_name)).to(
        eql(settings.merge(updated_part))
      )
    end
  end
end
