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

  let!(:posts_trackr) do
    stub_const("SocialFetchr::PostsTrackr", double)
  end

  context "no previous import selected" do
    context "there is a last post stored for the client" do
      it "check for updates since the last post"

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
        allow(SocialFetchr::TwitterFetchr).to(
          receive(:new)
          .with(social_credentials)
          .and_return(twitter_fetchr = double)
        )
        allow(twitter_fetchr).to(
          receive(:fetch_all)
          .with(count: 1)
          .and_return([OpenStruct.new(id: 1, text: "test text")])
        )
        expect(posts_trackr).to(
          receive(:store_last_processed_post)
          .with(client: social_client_key, post_id: 1)
        )
        described_class.check_updates(social_credentials)
      end
    end


  end

  xit "check for updates and passes the data to core postr" do
    allow(SocialFetchr::TwitterFetchr).to(
      receive(:new)
      .with(social_credentials)
      .and_return(twitter_fetch = double)
    )
    described_class.check_updates(social_credentials)
  end
end
