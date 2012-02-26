require "anmo/version"
require "anmo/application"
require "thin"

module Anmo
  def self.launch_server port = 8787
    Thin::Server.start("0.0.0.0", port, Anmo::Application.new)
  end
end
