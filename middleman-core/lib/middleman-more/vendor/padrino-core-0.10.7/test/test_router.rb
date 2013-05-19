require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/apps/simple')

describe "Router" do

  def setup
    Padrino.clear!
  end

  should "dispatch paths correctly" do
    app = lambda { |env|
      [200, {
        'X-ScriptName' => env['SCRIPT_NAME'],
        'X-PathInfo' => env['PATH_INFO'],
        'Content-Type' => 'text/plain'
      }, [""]]
    }
    map = Padrino::Router.new(
      { :path => '/bar',     :to => app },
      { :path => '/foo',     :to => app },
      { :path => '/foo/bar', :to => app }
    )

    res = Rack::MockRequest.new(map).get("/")
    assert res.not_found?

    res = Rack::MockRequest.new(map).get("/qux")
    assert res.not_found?

    res = Rack::MockRequest.new(map).get("/foo")
    assert res.ok?
    assert_equal "/foo", res["X-ScriptName"]
    assert_equal "/", res["X-PathInfo"]

    res = Rack::MockRequest.new(map).get("/foo/")
    assert res.ok?
    assert_equal "/foo", res["X-ScriptName"]
    assert_equal "/", res["X-PathInfo"]

    res = Rack::MockRequest.new(map).get("/foo/bar")
    assert res.ok?
    assert_equal "/foo/bar", res["X-ScriptName"]
    assert_equal "/", res["X-PathInfo"]

    res = Rack::MockRequest.new(map).get("/foo/bar/")
    assert res.ok?
    assert_equal "/foo/bar", res["X-ScriptName"]
    assert_equal "/", res["X-PathInfo"]

    res = Rack::MockRequest.new(map).get("/foo///bar//quux")
    assert_equal 200, res.status
    assert res.ok?
    assert_equal "/foo/bar", res["X-ScriptName"]
    assert_equal "//quux", res["X-PathInfo"]

    res = Rack::MockRequest.new(map).get("/foo/quux", "SCRIPT_NAME" => "/bleh")
    assert res.ok?
    assert_equal "/bleh/foo", res["X-ScriptName"]
    assert_equal "/quux", res["X-PathInfo"]

    res = Rack::MockRequest.new(map).get("/bar", 'HTTP_HOST' => 'foo.org')
    assert res.ok?
    assert_equal "/bar", res["X-ScriptName"]
    assert_equal "/", res["X-PathInfo"]

    res = Rack::MockRequest.new(map).get("/bar/", 'HTTP_HOST' => 'foo.org')
    assert res.ok?
    assert_equal "/bar", res["X-ScriptName"]
    assert_equal "/", res["X-PathInfo"]
  end

  should "dispatches hosts correctly" do
    map = Padrino::Router.new(
     { :host => "foo.org", :to => lambda { |env|
       [200,
        { "Content-Type" => "text/plain",
          "X-Position" => "foo.org",
          "X-Host" => env["HTTP_HOST"] || env["SERVER_NAME"],
        }, [""]]}},
     { :host => "subdomain.foo.org", :to => lambda { |env|
       [200,
        { "Content-Type" => "text/plain",
          "X-Position" => "subdomain.foo.org",
          "X-Host" => env["HTTP_HOST"] || env["SERVER_NAME"],
        }, [""]]}},
     { :host => /.*\.bar.org/, :to => lambda { |env|
       [200,
        { "Content-Type" => "text/plain",
          "X-Position" => "bar.org",
          "X-Host" => env["HTTP_HOST"] || env["SERVER_NAME"],
        }, [""]]}}
     )

     res = Rack::MockRequest.new(map).get("/", "HTTP_HOST" => "bar.org")
     assert res.not_found?

     res = Rack::MockRequest.new(map).get("/", "HTTP_HOST" => "at.bar.org")
     assert res.ok?
     assert_equal "bar.org", res["X-Position"]

     res = Rack::MockRequest.new(map).get("/", "HTTP_HOST" => "foo.org")
     assert res.ok?
     assert_equal "foo.org", res["X-Position"]

     res = Rack::MockRequest.new(map).get("/", "HTTP_HOST" => "subdomain.foo.org", "SERVER_NAME" => "foo.org")
     assert res.ok?
     assert_equal "subdomain.foo.org", res["X-Position"]
  end

  should "works with padrino core applications" do
    Padrino.mount("simple_demo").host("padrino.org")
    assert_equal ["simple_demo"], Padrino.mounted_apps.map(&:name)
    assert_equal ["padrino.org"], Padrino.mounted_apps.map(&:app_host)

    res = Rack::MockRequest.new(Padrino.application).get("/")
    assert res.not_found?

    res = Rack::MockRequest.new(Padrino.application).get("/", "HTTP_HOST" => "bar.org")
    assert res.not_found?

    res = Rack::MockRequest.new(Padrino.application).get("/", "HTTP_HOST" => "padrino.org")
    assert res.ok?
  end

  should "works with padrino applications" do
    Padrino.mount("simple_demo").to("/foo").host(/.*\.padrino.org/)

    res = Rack::MockRequest.new(Padrino.application).get("/")
    assert res.not_found?

    res = Rack::MockRequest.new(Padrino.application).get("/", "HTTP_HOST" => "bar.org")
    assert res.not_found?

    res = Rack::MockRequest.new(Padrino.application).get("/", "HTTP_HOST" => "padrino.org")
    assert res.not_found?

    res = Rack::MockRequest.new(Padrino.application).get("/none", "HTTP_HOST" => "foo.padrino.org")
    assert res.not_found?

    res = Rack::MockRequest.new(Padrino.application).get("/foo", "HTTP_HOST" => "bar.padrino.org")
    assert res.ok?

    res = Rack::MockRequest.new(Padrino.application).get("/foo/", "HTTP_HOST" => "bar.padrino.org")
    assert res.ok?
  end
end
