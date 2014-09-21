require "social_postr/adapters/redbooth"
require "timecop"

describe SocialPostr::Adapters::Redbooth do
  let(:task_desc) { "created by task_watchr" }
  let(:task_is_private) { true }
  let(:adapter_settings) do
    {
      token:         ENV["REDBOOTH_TOKEN"],
      project_id:    ENV["REDBOOTH_PROJECT_ID"],
      task_list_id:  ENV["REDBOOTH_TASK_LIST_ID"],
      task_description: task_desc,
      task_private: task_is_private
    }
  end
  subject { described_class.new(adapter_settings) }

  let(:task_name) { "test task" }

  VCR.configure do |c|
    %w(
      REDBOOTH_TOKEN
      REDBOOTH_REFRESH_TOKEN
    ).each do |const|
      c.filter_sensitive_data("<#{const}>") { ENV[const] }
    end
  end

  it "creates task" do
    VCR.use_cassette("redbooth_task_creation") do
      creation_result = subject.post_task(task_name)

      expect(creation_result).to(
        include(
          "type" => "Task",
          "name" => task_name,
          "is_private" => task_is_private,
          "description" => task_desc
        )
      )
    end
  end

  it "raise an error if token is expired" do
    Timecop.travel(Time.now + 7200) do
      VCR.use_cassette("redbooth_token_expires") do
        expect { subject.post_task(task_name) }.to(
          raise_exception(SocialPostr::Adapters::Errors::ExpiredToken)
        )
      end
    end
  end
end
