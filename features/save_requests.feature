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
