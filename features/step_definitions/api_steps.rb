When /^I execute the following code in a new thread$/ do |code|
  Thread.new do
    eval code
  end
end

When /^I execute the code$/ do |code|
  eval code
end

Then /^I see an anmo server on port (\d+)$/ do |port|
  response = nil

  timeout 5 do
    while response.nil?
      response = HTTParty.get("http://localhost:#{port}") rescue nil
    end
  end

  response.body.should include "Not Found"
end

Given /^an anmo server$/ do
  Thread.new do
    Anmo.launch_server
  end
  timeout 5 do
    response = nil
    while response.nil?
      response = HTTParty.get("http://localhost:8787") rescue nil
    end
    sleep 0.1
  end
end

When /^I request the uri "([^"]*)"$/ do |uri|
  @response = HTTParty.get(uri)
end

When /^I request the uri "([^"]*)" with the headers$/ do |uri, headers|
  headers = JSON.parse(headers)
  @response = HTTParty.get(uri, :headers => headers)
end

Then /^I should see the response body "([^"]*)"$/ do |body|
  @response.body.should == body
end

Then /^I should see the response code (\d+)$/ do |code|
  @response.code.should == code.to_i
end
