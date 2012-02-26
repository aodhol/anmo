Feature: API
  In order to easily modify mock APIs from by ruby code
  As a developer
  I want a simple API to hack against

  Scenario: Launch a server
    When I execute the code
    """
    require "anmo"
    Anmo.launch_server
    """
    Then I see an anmo server on port 8787

  Scenario: Launch a server with a port
    When I execute the code
    """
    require "anmo"
    Anmo.launch_server 9393
    """
    Then I see an anmo server on port 9393
