require 'spec/expectations'
require 'selenium'

# "before all"
browser = Selenium::SeleniumDriver.new("localhost", 4444, "*chrome", "http://localhost", 15000)

Before do
  @browser = browser
  @browser.start
end

After do
  @browser.stop
end

# "after all"
at_exit do
  browser.close rescue nil
end