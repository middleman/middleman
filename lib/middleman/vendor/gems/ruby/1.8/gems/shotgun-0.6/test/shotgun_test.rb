require 'test/unit'
require 'rack/mock'
require 'shotgun'

class ShotgunTest < Test::Unit::TestCase
  def setup
    @rackup_file = "#{File.dirname(__FILE__)}/test.ru"
    @shotgun = Shotgun.new(@rackup_file)
  end

  def test_knows_the_rackup_file
    assert_equal @rackup_file, @shotgun.rackup_file
  end

  def test_processes_requests
    request = Rack::MockRequest.new(@shotgun)
    res = request.get("/")
    assert_equal 200, res.status
    assert_equal "BANG!", res.body
    assert_equal "text/plain", res.headers['Content-Type']
  end
end
