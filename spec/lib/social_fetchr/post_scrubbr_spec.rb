require "social_fetchr/post_scrubbr"

describe SocialFetchr::PostScrubbr do

  it "scrubs post if it starts from @smthng" do
    expect(
      described_class.scrub("@handle mention with @handle starts the text")
    ).to eql("mention with @handle starts the text")
  end

  it "does not remove anything else" do
    expect(described_class.scrub("mention with @handle inside the text"))
      .to eql("mention with @handle inside text")
  end

end
