require "minitest/pride"
require "minitest/autorun"
require "minitest/unit"
require "rack/test"
require File.expand_path(File.join(File.dirname(__FILE__), "../../lib/anmo/application"))

module Anmo
  class ApplicationTest < MiniTest::Unit::TestCase
    include Rack::Test::Methods

    def app
      Application.new
    end

    def test_404s_if_object_does_not_exist
      get "/bla/bla/bla.json"
      assert_equal "Not Found", last_response.body
      assert last_response.not_found?
    end

    def test_stores_mock_data
      header "anmo_body", "please save this"
      header "anmo_path", "/this/is/the/path.object"
      put "__CREATE__"

      get "/this/is/the/path.object"
      assert_equal "please save this", last_response.body
      assert last_response.ok?
    end

    def test_stores_status_code
      header "anmo_path", "/monkeys"
      header "anmo_http_status", 123
      put "__CREATE__"
      get "/monkeys"
      assert_equal 123, last_response.status
    end
  end
end
