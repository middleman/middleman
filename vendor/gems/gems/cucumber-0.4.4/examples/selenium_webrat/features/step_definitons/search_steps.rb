Given 'I am on the Google search page' do
  visit('http://www.google.com/')
end

When /I search for "(.*)"/ do |query|
  fill_in('q', :with => query)
  click_button 'Google Search'
  selenium.wait_for_page_to_load
end

Then /I should see a link to (.*)/ do |expected_url|
  click_link expected_url
end
