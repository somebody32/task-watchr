require "social_fetchr/post_trackr"
require "database_cleaner"

describe SocialFetchr::PostTrackr do
  let(:client) { "some_test_client" }
  let(:post_id) { "test_post_id" }

  it "stores and reads the last post" do
    DatabaseCleaner.cleaning do
      expect(described_class.last_processed_post(client: client)).to be_nil
      described_class.store_last_processed_post(
        client: client,
        post_id: post_id
      )
      expect(described_class.last_processed_post(client: client))
        .to eql(post_id)
    end
  end
end
