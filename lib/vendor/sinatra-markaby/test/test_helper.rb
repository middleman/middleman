require 'rubygems'
require 'test/unit'
require 'rack/test'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sinatra/markaby'

class Test::Unit::TestCase
  include Rack::Test::Methods

  attr_reader :app

  # Sets up a Sinatra::Base subclass defined with the block
  # given. Used in setup or individual spec methods to establish
  # the application.
  def mock_app(base=Sinatra::Base, &block)
    @app = Sinatra.new(base, &block)
  end
end
