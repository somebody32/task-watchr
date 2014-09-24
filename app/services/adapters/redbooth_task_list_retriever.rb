module Adapters
  module RedboothTaskListRetriever
    module_function

    def fetch_task_lists(token)
      task_lists_raw = Faraday.get do |req|
        req.url "https://redbooth.com/api/3/task_lists"
        req.headers["Authorization"] = "Bearer #{token}"
      end
      JSON.parse(task_lists_raw.body).map do |t|
        [t["name"], [t["id"], t["project_id"]].join("/")]
      end
    end
  end
end
