Given 'I am on the Google search page' do
  @browser.open('http://www.google.com/')
end

When /I search for "(.*)"/ do |query|
  @browser.type('q', query)   
  @browser.click 'btnG'
  @browser.wait_for_page_to_load
end

Then /I should see a link to (.*)/ do |expected_url|
  @browser.is_element_present("css=a[href='#{expected_url}']").should be_true
end
