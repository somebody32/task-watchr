require "social_fetchr/workers/updater"
require "sidekiq/testing"
require "database_cleaner"

describe SocialFetchr::Workers::Updater do

  it "knows about it's state" do
    Sidekiq::Testing.disable!
    DatabaseCleaner.cleaning do
      expect(described_class.running?).to eql(false)
      described_class.perform_async(token: "some_settings")
      expect(described_class.running?).to eql(true)
    end
    Sidekiq::Testing.fake!
  end

  context "running synchronously" do
    it "runs the fetcher"
  end

  context "running asynchronously" do
    it "runs the fetcher"
    it "ensures that the task will be enqued"
  end
end
