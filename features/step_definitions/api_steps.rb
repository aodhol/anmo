When /^I execute the code$/ do |code|
  Thread.new do
    eval code
  end
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
