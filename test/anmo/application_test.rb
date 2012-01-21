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

    def save_object path, body, status
      header "anmo_path", path
      header "anmo_body", body
      header "anmo_http_status", status
      put "__CREATE__"
    end

    def test_404s_if_object_does_not_exist
      get "/bla/bla/bla.json"
      assert_equal "Not Found", last_response.body
      assert last_response.not_found?
    end

    def test_stores_mock_data
      save_object "/this/is/the/path.object", "please save this", nil

      get "/this/is/the/path.object"
      assert_equal "please save this", last_response.body
      assert last_response.ok?
    end

    def test_stores_status_code
      save_object "/monkeys", nil, 123
      get "/monkeys"
      assert_equal 123, last_response.status
    end

    def test_allows_deleting_all_objects
      save_object "/this/is/the/path.object", "please save this", nil

      get "/this/is/the/path.object"
      first_response = last_response

      put "__DELETE_ALL__"

      get "/this/is/the/path.object"
      second_response = last_response

      assert_equal "please save this", first_response.body
      assert_equal "Not Found", second_response.body
      assert_equal 404, second_response.status
    end
  end
end
