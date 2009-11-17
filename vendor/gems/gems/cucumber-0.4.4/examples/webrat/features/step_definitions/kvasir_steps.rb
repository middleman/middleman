# Google is too hard to script with Mechanize
# Using a Norewgian search engine instead :-)
Given /^I am on the Kvasir search page$/ do
  visit('http://www.kvasir.no/')
end

When /^I search for "([^\"]*)"$/ do |query|
  fill_in('q', :with => query)
  click_button('sokeKnapp')
end

Then /^I should see$/ do |text|
  response_body.should contain(text)
end
