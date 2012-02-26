Feature: Save Requests
  In order to test applications against stable APIs
  As a developer
  I want to be able to mock http endpoints

  Scenario: Save object
    Given the headers
    """
    {
      "anmo_path": "/some/object",
      "anmo_body": "some data"
    }
    """
    When I issue a put request to "/__CREATE__"
    And I do a get request to "/some/object"
    Then I should see "some data"

  Scenario: Save object with http status code
    Given the headers
    """
    {
      "anmo_path": "/some/object",
      "anmo_http_status": 123
    }
    """
    When I issue a put request to "/__CREATE__"
    And I do a get request to "/some/object"
    Then the http status should be 123

  Scenario: Request without required headers 404s
    Given the headers
    """
    {
      "anmo_path": "/some/object",
      "anmo_required_headers": {"monkeys":"bananas", "mice": "cheese"}
    }
    """
    When I issue a put request to "/__CREATE__"
    And I do a get request to "/some/object"
    Then the http status should be 404

  Scenario: Request with required headers
    Given the headers
    """
    {
      "anmo_path": "/some/object",
      "anmo_body": "helloow",
      "anmo_required_headers": {"monkeys":"bananas", "mice": "cheese"}
    }
    """
    When I issue a put request to "/__CREATE__"
    And I do a get request to "/some/object" with the headers
    """
    {
      "monkeys": "bananas",
      "mice": "cheese"
    }
    """
    Then I should see "helloow"
    And the http status should be 200

  Scenario: Delete all saved objects
    Given the headers
    """
    {
      "anmo_path": "/some/object",
      "anmo_body": "some data"
    }
    """
    And I issue a put request to "/__CREATE__"
    And I issue a put request to "/__DELETE_ALL__"
    When I do a get request to "/some/object"
    Then I should see "Not Found"
    And the http status should be 404
