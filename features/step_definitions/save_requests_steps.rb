Given /^the headers$/ do |headers|
  @headers = JSON.parse(headers)
end

When /^I issue a put request to "([^"]*)"$/ do |path|
  @headers.each do |name, value|
    header name, value
  end
  put path
end

When /^I do a get request to "([^"]*)"$/ do |path|
  get path
end

Then /^I should see "([^"]*)"$/ do |text|
  last_response.body.should == text
end

Then /^the http status should be (\d+)$/ do |status|
  last_response.status.should == status.to_i
end
