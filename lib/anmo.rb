require "anmo/version"
require "anmo/application"
require "thin"

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
end
