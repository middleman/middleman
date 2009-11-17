# This is an example of how you can set up screenshots for your
# browser testing. Just run cucumber with --format html --out report.html
#
# This examples currently only works on OS X, but adding support for other
# platform should be easy - as long as there is a command line tool to take
# a picture of the desktop.
module Screenshots
  def add_screenshot
    id = "screenshot-#{Time.new.to_i}"
    take_screenshot(id)
    embed("#{id}.png", "image/png")
  end

  if Cucumber::OS_X
    def take_screenshot(id)
      `screencapture -t png #{id}.png`
    end
  else
    # Other platforms...
    def take_screenshot(id)
      STDERR.puts "Sorry - no screenshots on your platform yet."
    end
  end
end

After do
  add_screenshot
end

# Other variants
#
# Only take screenshot on failures
#
#   After do |scenario|
#     add_screenshot if scenario.failed?
#   end
#
# Only take screenshot for scenarios or features tagged @screenshot
#
#   After(@screenshot) do
#     add_screenshot
#   end

World(Screenshots)