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
      { :path => '/foo/bar', :to => app },
      { :path => '/foo',     :to => app }
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

  should "dispatch requests to cascade mounted apps" do
    app = lambda { |env|
      scary = !!env['PATH_INFO'].match(/scary/)
      [scary ? 404 : 200, {
        'X-ScriptName' => env['SCRIPT_NAME'],
        'X-PathInfo' => env['PATH_INFO'],
        'Content-Type' => 'text/plain'
      }, [""]]
    }
    api = lambda { |env|
      spooky = !!env['QUERY_STRING'].match(/spooky/)
      [spooky ? 200 : 404, {
        'X-API' => spooky,
        'X-ScriptName' => env['SCRIPT_NAME'],
        'X-PathInfo' => env['PATH_INFO'],
        'Content-Type' => 'application/json'
      }, [""]]
    }
    map = Padrino::Router.new(
      { :path => '/bar',     :to => api },
      { :path => '/bar',     :to => app }
    )

    res = Rack::MockRequest.new(map).get("/werewolf")
    assert_equal 404, res.status
    assert_equal nil, res["X-API"]
    assert_equal nil, res["X-ScriptName"]
    assert_equal nil, res["X-PathInfo"]

    res = Rack::MockRequest.new(map).get("/bar/mitzvah")
    assert res.ok?
    assert_equal nil, res["X-API"]
    assert_equal 'text/plain', res["Content-Type"]
    assert_equal "/bar", res["X-ScriptName"]
    assert_equal "/mitzvah", res["X-PathInfo"]

    res = Rack::MockRequest.new(map).get("/bar?spooky")
    assert res.ok?
    assert_equal true, res["X-API"]
    assert_equal 'application/json', res["Content-Type"]
    assert_equal "/bar", res["X-ScriptName"]
    assert_equal "/", res["X-PathInfo"]

    res = Rack::MockRequest.new(map).get("/bar/scary")
    assert_equal 404, res.status
    assert_equal nil, res["X-API"]
    assert_equal 'text/plain', res["Content-Type"]
    assert_equal "/bar", res["X-ScriptName"]
    assert_equal "/scary", res["X-PathInfo"]
  end

  should "dispatch requests to cascade mounted apps and not cascade ok statuses" do

    api = mock_app do
      get 'scary' do
        "1"
      end
      set :cascade, true
    end

    app = mock_app do
      get 'scary' do
        "2"
      end
      set :cascade, false
    end

    app2 = mock_app do
      get 'terrifying' do
        ""
      end
    end

    map = Padrino::Router.new(
        { :path => '/bar',     :to => api },
        { :path => '/bar',   :to => app  },
        { :path => '/bar',     :to => app2 }
    )

    res = Rack::MockRequest.new(map).get("/bar/scary")
    assert res.ok?
    #asserting that on ok we're good to go
    assert_equal "1", res.body

    res = Rack::MockRequest.new(map).get("/bar/terrifying")
    assert !res.ok?

  end

  should "dispatch requests to cascade mounted apps until it sees a cascade == false or []g" do
    app = mock_app do
      get 'scary' do
        ""
      end
      set :cascade, []
    end

    app2 = mock_app do
      get 'terrifying' do
        ""
      end
    end

    map = Padrino::Router.new(
        { :path => '/bar',   :to => app  },
        { :path => '/bar',     :to => app2 }
    )

    request_case = lambda {
      Rack::MockRequest.new(map).get("/bar/terrifying")
    }

    app.cascade = false
    assert !request_case.call.ok?

    app.cascade = true
    assert request_case.call.ok?
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
