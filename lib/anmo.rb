require "anmo/version"
require "anmo/application"
require "thin"
require "httparty"
require "json"

module Anmo
  def self.server
    @server ||= "http://localhost:#{@port}"
  end

  def self.server= server
    @server = server
  end

  def self.server_version
    HTTParty.get("#{server}/__VERSION__").body
  end

  def self.launch_server port = 8787
    @port = port
    Thin::Server.start("0.0.0.0", port, Anmo::Application.new)
  end

  def self.create_request options
    HTTParty.post("#{server}/__CREATE_OBJECT__", {:body => options.to_json, :headers => {"Content-Type" => "application/json"}})
  end

  def self.delete_all
    HTTParty.post("#{server}/__DELETE_ALL_OBJECTS__")
  end

  def self.requests
    json = HTTParty.get("#{server}/__REQUESTS__")
    JSON.parse(json.body)
  end

  def self.delete_all_requests
    HTTParty.post("#{server}/__DELETE_ALL_REQUESTS__")
  end

  def self.stored_objects
    json = HTTParty.get("#{server}/__OBJECTS__")
    JSON.parse(json.body)
  end

  def self.running?
    HTTParty.get("#{server}/__ALIVE__").code == 200 rescue false
  end
end
