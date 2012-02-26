require "minitest/pride"
require "minitest/autorun"
require "minitest/unit"
require "rack/test"
require "json"
require File.expand_path(File.join(File.dirname(__FILE__), "../../lib/anmo/application"))

module Anmo
  class ApplicationTest < MiniTest::Unit::TestCase
    include Rack::Test::Methods

    def app
      Application.new
    end

    def save_object path, body, status, required_headers
      options = {
        :path => path,
        :body => body,
        :status => status,
        :required_headers => required_headers
      }
      put "__CREATE__", options.to_json
    end

    def test_404s_if_object_does_not_exist
      get "/bla/bla/bla.json"
      assert_equal "Not Found", last_response.body
      assert last_response.not_found?
    end

    def test_stores_mock_data
      save_object "/this/is/the/path.object", "please save this", nil, nil
      assert_equal 201, last_response.status

      get "/this/is/the/path.object"
      assert_equal "please save this", last_response.body
      assert last_response.ok?
    end

    def test_stores_status_code
      save_object "/monkeys", nil, 123, nil
      get "/monkeys"
      assert_equal 123, last_response.status
    end

    def test_allows_deleting_all_objects
      save_object "/this/is/the/path.object", "please save this", nil, nil

      get "/this/is/the/path.object"
      first_response = last_response

      put "__DELETE_ALL__"
      assert_equal 200, last_response.status

      get "/this/is/the/path.object"
      second_response = last_response

      assert_equal "please save this", first_response.body
      assert_equal "Not Found", second_response.body
      assert_equal 404, second_response.status
    end

    def test_404s_if_request_does_not_have_required_headers
      save_object "/oh/hai", nil, nil, {"ruby" => "hipsters", "meh" => "bleh"}
      get "/oh/hai"
      assert_equal 404, last_response.status
    end

    def test_returns_value_if_request_has_required_headers
      save_object "/oh/hai", "the content", nil, {"lol-ruby" => "hipsters", "meh" => "bleh"}
      header "lol-ruby", "hipsters"
      header "meh", "bleh"
      get "/oh/hai"
      assert_equal 200, last_response.status
      assert_equal "the content", last_response.body
    end

    def test_returns_the_last_added_object_first
      save_object "/oh/hai", "the first content", nil, nil
      save_object "/oh/hai", "the second content", nil, nil
      get "/oh/hai"
      assert_equal "the second content", last_response.body
    end
  end
end
