require 'spec/expectations'

# START HACK
# Webrat's Selenium wrongly assumes Rails in available. # We'll just fool it...
module ActionController
  class IntegrationTest
  end
end

def silence_stream(*args)
  yield if block_given?
end
# END HACK

# RSpec
require 'spec/expectations'

# Webrat
require 'webrat'

Webrat.configure do |config|
  config.mode = :selenium
end

World do
  session = Webrat::SeleniumSession.new
  session.extend(Webrat::Methods)
  session.extend(Webrat::Selenium::Methods)
  session.extend(Webrat::Selenium::Matchers)
  session
end

# START HACK
# Disable Rails-specific code
class Webrat::Selenium::ApplicationServer
  def self.boot
    
    STDOUT.puts "Starting app server"
  end
  
  def self.stop_at_exit
    STDOUT.puts "Stopping app server"
  end
end
# END HACK
