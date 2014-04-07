require "rubygems"
require "bundler/setup"

require "faraday"
require "multi_json"

class Repositories
  def initialize(connector = Faraday.new, parser = MultiJson) # dependency injection
    @connector = connector
    @parser = parser
  end

  def fetch(user)
    response = @connector.get("https://api.github.com/users/#{user}/repos")

    if response.status == 404
      ["I couldn't find the user '#{user}'. Please check the name and try again."]
    else
      repos = @parser.load(response.body)
      extract_names(repos)
    end
  end

  private

  def extract_names(repos) # extract value of "name" key for each hash in result
    repos.map { |repo| repo["name"] }
  end
end
