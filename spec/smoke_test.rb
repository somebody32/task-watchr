require "faraday"
require "social_fetchr"
require "social_postr/adapters/settings_repository"
require "pry"

#initial settings import
SocialPostr::Adapters::SettingsRepository.save(:redbooth, {
  key:           ENV["REDBOOTH_KEY"],
  secret:        ENV["REDBOOTH_SECRET"],
  token:         ENV["REDBOOTH_TOKEN"],
  project_id:    ENV["REDBOOTH_PROJECT_ID"],
  task_list_id:  ENV["REDBOOTH_TASK_LIST_ID"],
  task_description: "test"
})

# delete all the tasks at the specified task list
puts "requesting current tasks"
raw_tasks = Faraday.get do |req|
  req.url "https://redbooth.com/api/3/tasks?order=id&task_list_id=#{ENV['REDBOOTH_TASK_LIST_ID']}&status=new"
  req.headers["Authorization"] = "Bearer #{ENV['REDBOOTH_TOKEN']}"
end

puts "deleting current tasks"
tasks_ids = JSON.parse(raw_tasks.body).map { |t| t["id"] }
tasks_ids.each do |t_id|
  Faraday.delete do |req|
    req.url "https://redbooth.com/api/3/tasks/#{t_id}"
    req.headers["Authorization"] = "Bearer #{ENV['REDBOOTH_TOKEN']}"
  end
end

puts "importing tasks from twitter"
SocialFetchr.process_all(
  app_key:       ENV["TWITTER_KEY"],
  app_secret:    ENV["TWITTER_SECRET"],
  client_key:    ENV["TWITTER_ACCESS_TOKEN"],
  client_secret: ENV["TWITTER_ACCESS_SECRET"]
)

puts "requesting current tasks and matching with originals"
raw_tasks = Faraday.get do |req|
  req.url "https://redbooth.com/api/3/tasks?order=id&task_list_id=#{ENV['REDBOOTH_TASK_LIST_ID']}&status=new"
  req.headers["Authorization"] = "Bearer #{ENV['REDBOOTH_TOKEN']}"
end

puts JSON.parse(raw_tasks.body).map { |t| t["name"] }
