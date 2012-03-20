require "anmo/version"
require "anmo/application"
require "thin"
require "httparty"
require "json"

module Anmo
  class << self
    attr_accessor :server
  end

  def self.launch_server port = 8787
    Thin::Server.start("0.0.0.0", port, Anmo::Application.new)
  end

  def self.create_request options
    HTTParty.put("#{server}/__CREATE__", :body => options.to_json)
  end

  def self.delete_all
    HTTParty.put("#{server}/__DELETE_ALL__")
  end

  def self.requests
    json = HTTParty.get("#{server}/__REQUESTS__")
    JSON.parse(json.body)
  end

  def self.delete_all_requests
    HTTParty.get("#{server}/__DELETE_ALL_REQUESTS__")
  end

  def self.stored_objects
    json = HTTParty.get("#{server}/__STORED_OBJECTS__")
    JSON.parse(json.body)
  end
end
