require "rack"
require "rack/test"
require "httparty"
require File.join(File.dirname(__FILE__), "../../lib/anmo/application")

World(Rack::Test::Methods)

def app
  Anmo::Application.new
end
