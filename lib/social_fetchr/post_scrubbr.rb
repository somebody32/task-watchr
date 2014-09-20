module SocialFetchr
  module PostScrubbr
    module_function

    def scrub(post)
      post.sub(/^(@\S+)/, "").strip
    end
  end
end
