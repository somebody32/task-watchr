require "social_fetchr"
require "ostruct"

describe SocialFetchr do
  let(:social_client_key) { "some_client_key" }
  let(:social_credentials) do
    {
      app_key:       "some_key",
      app_secret:    "some_secret",
      client_key:    social_client_key,
      client_secret: "some_client_secret"
    }
  end

  let(:posts_trackr) { SocialFetchr::PostTrackr }
  let!(:task_postr) do
    stub_const("TaskPostr", double(post_task: nil))
  end

  let(:twitter_fetchr) { double }
  before(:each) do
    allow(SocialFetchr::TwitterFetchr).to(
      receive(:new)
      .with(social_credentials)
      .and_return(twitter_fetchr)
    )
  end

  context "no previous import selected" do
    context "there is a last post stored for the client" do
      let(:last_post_id) { "stored_id" }
      let(:new_mentions) do
        [
          OpenStruct.new(id: 2, text: "@yourhandle test text 2"),
          OpenStruct.new(id: 1, text: "@yourhandle test text")
        ]
      end

      before do
        allow(posts_trackr).to(
          receive(:last_processed_post)
          .with(client: social_client_key)
          .and_return last_post_id
        )

        allow(twitter_fetchr).to(
          receive(:fetch_since)
          .with(since_id: last_post_id)
          .and_return(new_mentions)
        )
      end

      it "pass all new posts to postr" do
        expect(task_postr).to(
          receive(:post_task)
          .with("@yourhandle test text")
          .ordered
        )
        expect(task_postr).to(
          receive(:post_task)
          .with("@yourhandle test text 2")
          .ordered
        )
        described_class.check_updates(social_credentials)
      end

      it "stores the last processed post" do
        expect(posts_trackr).to(
          receive(:store_last_processed_post)
          .with(client: social_client_key, post_id: new_mentions.first.id)
        )

        described_class.check_updates(social_credentials)
      end
    end

    context "there is no last post for the client" do
      before do
        allow(posts_trackr).to(
          receive(:last_processed_post)
          .with(client: social_client_key)
          .and_return nil
        )
      end

      it "remembers the last social post" do
        first_mention = OpenStruct.new(id: 1, text: "@yourhandle test text")
        allow(twitter_fetchr).to(
          receive(:fetch_all)
          .with(count: 1)
          .and_return([first_mention])
        )

        expect(posts_trackr).to(
          receive(:store_last_processed_post)
          .with(client: social_client_key, post_id: first_mention.id)
        )
        described_class.check_updates(social_credentials)
      end

      it "does not fail if there are no posts" do
        allow(twitter_fetchr).to(
          receive(:fetch_all)
          .with(count: 1)
          .and_return([])
        )
        expect(posts_trackr).not_to receive(:store_last_processed_post)
        described_class.check_updates(social_credentials)
      end
    end
  end
end
