require File.expand_path(File.dirname(__FILE__) + '/helper')

class FooError < RuntimeError; end


describe "Routing" do
  setup do
    Padrino::Application.send(:register, Padrino::Rendering)
    Padrino::Rendering::DEFAULT_RENDERING_OPTIONS[:strict_format] = false
  end

  should "serve static files with simple cache control" do
    mock_app do
      set :static_cache_control, :public
      set :public_folder, File.dirname(__FILE__)
    end
    get "/#{File.basename(__FILE__)}"
    assert headers.has_key?('Cache-Control')
    assert_equal headers['Cache-Control'], 'public'
  end # static simple

  should "serve static files with cache control and max_age" do
    mock_app do
      set :static_cache_control, [:public, :must_revalidate, {:max_age => 300}]
      set :public_folder, File.dirname(__FILE__)
    end
    get "/#{File.basename(__FILE__)}"
    assert headers.has_key?('Cache-Control')
    assert_equal headers['Cache-Control'], 'public, must-revalidate, max-age=300'
  end # static max_age

  should 'ignore trailing delimiters for basic route' do
    mock_app do
      get("/foo"){ "okey" }
      get(:test) { "tester" }
    end
    get "/foo"
    assert_equal "okey", body
    get "/foo/"
    assert_equal "okey", body
    get "/test"
    assert_equal "tester", body
    get "/test/"
    assert_equal "tester", body
  end

  should 'fail with unrecognized route exception when not found' do
    mock_app do
      get(:index){ "okey" }
    end
    get @app.url_for(:index)
    assert_equal "okey", body
    assert_raises(Padrino::Routing::UnrecognizedException) {
      get @app.url_for(:fake)
    }
  end

  should 'accept regexp routes' do
    mock_app do
      get(%r{/fob|/baz}) { "regexp" }
      get("/foo")        { "str" }
      get %r{/([0-9]+)/} do |num|
       "Your lucky number: #{num} #{params[:captures].first}"
      end
      get /\/page\/([0-9]+)|\// do |num|
        "My lucky number: #{num} #{params[:captures].first}"
      end
    end
    get "/foo"
    assert_equal "str", body
    get "/fob"
    assert_equal "regexp", body
    get "/baz"
    assert_equal "regexp", body
    get "/1234/"
    assert_equal "Your lucky number: 1234 1234", body
    get "/page/99"
    assert_equal "My lucky number: 99 99", body
  end

  should 'accept regexp routes with generate with :generate_with' do
    mock_app do
      get(%r{/fob|/baz}, :name => :foo, :generate_with => '/fob') { "regexp" }
    end
    assert_equal "/fob", @app.url(:foo)
  end

  should "parse routes with question marks" do
    mock_app do
      get("/foo/?"){ "okey" }
      post('/unauthenticated/?') { "no access" }
    end
    get "/foo"
    assert_equal "okey", body
    get "/foo/"
    assert_equal "okey", body
    post "/unauthenticated"
    assert_equal "no access", body
    post "/unauthenticated/"
    assert_equal "no access", body
  end

  should 'match correctly similar paths' do
    mock_app do
      get("/my/:foo_id"){ params[:foo_id] }
      get("/my/:bar_id/bar"){ params[:bar_id] }
    end
    get "/my/1"
    assert_equal "1", body
    get "/my/2/bar"
    assert_equal "2", body
  end

  should "match user agents" do
    app = mock_app do
      get("/main", :agent => /IE/){ "hello IE" }
      get("/main"){ "hello" }
    end
    get "/main"
    assert_equal "hello", body
    get "/main", {}, {'HTTP_USER_AGENT' => 'This is IE'}
    assert_equal "hello IE", body
  end

  should "use regex for parts of a route" do
    app = mock_app do
      get("/main/:id", :id => /\d+/){ "hello #{params[:id]}" }
    end
    get "/main/123"
    assert_equal "hello 123", body
    get "/main/asd"
    assert_equal 404, status
  end

  should "not generate overlapping head urls" do
    app = mock_app do
      get("/main"){ "hello" }
      post("/main"){ "hello" }
    end
    assert_equal 3, app.routes.size, "should generate GET, HEAD and PUT"
    assert_equal ["GET"],  app.routes[0].conditions[:request_method]
    assert_equal ["HEAD"], app.routes[1].conditions[:request_method]
    assert_equal ["POST"], app.routes[2].conditions[:request_method]
  end

  should 'generate basic urls' do
    mock_app do
      get(:foo){ "/foo" }
      get(:foo, :with => :id){ |id| "/foo/#{id}" }
      get([:foo, :id]){ |id| "/foo/#{id}" }
      get(:hash, :with => :id){ url(:hash, :id => 1) }
      get([:hash, :id]){ url(:hash, :id => 1) }
      get(:array, :with => :id){ url(:array, 23) }
      get([:array, :id]){ url(:array, 23) }
      get(:hash_with_extra, :with => :id){ url(:hash_with_extra, :id => 1, :query => 'string') }
      get([:hash_with_extra, :id]){ url(:hash_with_extra, :id => 1, :query => 'string') }
      get(:array_with_extra, :with => :id){ url(:array_with_extra, 23, :query => 'string') }
      get([:array_with_extra, :id]){ url(:array_with_extra, 23, :query => 'string') }
      get("/old-bar/:id"){ params[:id] }
      post(:mix, :map => "/mix-bar/:id"){ params[:id] }
      get(:mix, :map => "/mix-bar/:id"){ params[:id] }
    end
    get "/foo"
    assert_equal "/foo", body
    get "/foo/123"
    assert_equal "/foo/123", body
    get "/hash/2"
    assert_equal "/hash/1", body
    get "/array/23"
    assert_equal "/array/23", body
    get "/hash_with_extra/1"
    assert_equal "/hash_with_extra/1?query=string", body
    get "/array_with_extra/23"
    assert_equal "/array_with_extra/23?query=string", body
    get "/old-bar/3"
    assert_equal "3", body
    post "/mix-bar/4"
    assert_equal "4", body
    get "/mix-bar/4"
    assert_equal "4", body
  end

  should 'generate url with format' do
    mock_app do
      get(:a, :provides => :any){ url(:a, :format => :json) }
      get(:b, :provides => :js){ url(:b, :format => :js) }
      get(:c, :provides => [:js, :json]){ url(:c, :format => :json) }
      get(:d, :provides => [:html, :js]){ url(:d, :format => :js, :foo => :bar) }
    end
    get "/a.js"
    assert_equal "/a.json", body
    get "/b.js"
    assert_equal "/b.js", body
    get "/b.ru"
    assert_equal 405, status
    get "/c.js"
    assert_equal "/c.json", body
    get "/c.json"
    assert_equal "/c.json", body
    get "/c.ru"
    assert_equal 405, status
    get "/d"
    assert_equal "/d.js?foo=bar", body
    get "/d.js"
    assert_equal "/d.js?foo=bar", body
    get "/e.xml"
    assert_equal 404, status
  end

  should 'use padrino url method' do
    mock_app do
    end

    assert_equal @app.method(:url).owner, Padrino::Routing::ClassMethods
  end

  should 'work correctly with sinatra redirects' do
    mock_app do
      get(:index)  { redirect url(:index) }
      get(:google) { redirect "http://google.com" }
      get("/foo")  { redirect "/bar" }
      get("/bar")  { "Bar" }
    end

    get "/"
    assert_equal "http://example.org/", headers['Location']
    get "/google"
    assert_equal "http://google.com", headers['Location']
    get "/foo"
    assert_equal "http://example.org/bar", headers['Location']
  end

  should "return 406 on Accept-Headers it does not provide" do
    mock_app do
      get(:a, :provides => [:html, :js]){ content_type }
    end

    get "/a", {}, {"HTTP_ACCEPT" => "application/yaml"}
    assert_equal 406, status
  end

  should "return 406 on file extensions it does not provide and flag is set" do
    mock_app do
      enable :treat_format_as_accept
      get(:a, :provides => [:html, :js]){ content_type }
    end

    get "/a.xml", {}, {}
    assert_equal 406, status
  end

  should "return 404 on file extensions it does not provide and flag is not set" do
    mock_app do
      get(:a, :provides => [:html, :js]){ content_type }
    end

    get "/a.xml", {}, {}
    assert_equal 405, status
  end

  should "not set content_type to :html if Accept */* and html not in provides" do
    mock_app do
      get("/foo", :provides => [:json, :xml]) { content_type.to_s }
    end

    get '/foo', {}, { 'HTTP_ACCEPT' => '*/*;q=0.5' }
    assert_equal 'json', body
  end

  should "set content_type to :json if Accept contains */*" do
    mock_app do
      get("/foo", :provides => [:json]) { content_type.to_s }
    end

    get '/foo', {}, { 'HTTP_ACCEPT' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' }
    assert_equal 'json', body
  end

  should "set content_type to :json if render => :json" do
    mock_app do
      get("/foo"){ render :foo => :bar }
    end

    get '/foo'
    assert_equal 'application/json;charset=utf-8', content_type
  end

  should 'set and get content_type' do
    mock_app do
      get("/foo"){ content_type(:json); content_type.to_s }
    end
    get "/foo"
    assert_equal 'application/json;charset=utf-8', content_type
    assert_equal 'json', body
  end

  should "send the appropriate number of params" do
    mock_app do
      get('/id/:user_id', :provides => [:json]) { |user_id, format| user_id}
    end
    get '/id/5.json'
    assert_equal '5', body
  end

  should "allow .'s in param values" do
    mock_app do
      get('/id/:email', :provides => [:json]) { |email, format| [email, format] * '/' }
    end
    get '/id/foo@bar.com.json'
    assert_equal 'foo@bar.com/json', body
  end

  should "set correct content_type for Accept not equal to */* even if */* also provided" do
    mock_app do
      get("/foo", :provides => [:html, :js, :xml]) { content_type.to_s }
    end

    get '/foo', {}, { 'HTTP_ACCEPT' => 'application/javascript, */*;q=0.5' }
    assert_equal 'js', body
  end

  should "return the first content type in provides if accept header is empty" do
    mock_app do
      get(:a, :provides => [:js]){ content_type.to_s }
    end

    get "/a", {}, {}
    assert_equal "js", body
  end

  should "not default to HTML if HTML is not provided and no type is given" do
    mock_app do
      get(:a, :provides => [:js]){ content_type }
    end

    get "/a", {}, {}
    assert_equal "application/javascript;charset=utf-8", content_type
  end

  should "not match routes if url_format and http_accept is provided but not included" do
    mock_app do
      get(:a, :provides => [:js, :html]){ content_type }
    end

    get "/a.xml", {}, {"HTTP_ACCEPT" => "text/html"}
    assert_equal 405, status
  end

  should "generate routes for format simple" do
    mock_app do
      get(:foo, :provides => [:html, :rss]) { render :haml, "Test" }
    end
    get "/foo"
    assert_equal "Test\n", body
    get "/foo.rss"
    assert_equal "Test\n", body
  end

  should "should inject the controller name into the request" do
    mock_app do
      controller :posts do
        get(:index) { request.controller }
        controller :mini do
          get(:index) { request.controller }
        end
      end
    end
    get "/posts"
    assert_equal "posts", body
    get "/mini"
    assert_equal "mini", body
  end

  should "support not_found" do
    mock_app do
      not_found do
        response.status = 404
        'whatever'
      end

      get :index, :map => "/" do
        'index'
      end
    end
    get '/something'
    assert_equal 'whatever', body
    assert_equal 404, status
    get '/'
    assert_equal 'index', body
    assert_equal 200, status
  end

  should "should inject the route into the request" do
    mock_app do
      controller :posts do
        get(:index) { request.route_obj.named.to_s }
      end
    end
    get "/posts"
    assert_equal "posts_index", body
  end

  should "preserve the format if you set it manually" do
    mock_app do
      before do
        params[:format] = "json"
      end

      get "test", :provides => [:html, :json] do
        content_type.inspect
      end
    end
    get "/test"
    assert_equal ":json", body
    get "/test.html"
    assert_equal ":json", body
    get "/test.php"
    assert_equal ":json", body
  end

  should "correctly accept '.' in the route" do
    mock_app do
      get "test.php", :provides => [:html, :json] do
        content_type.inspect
      end
    end
    get "/test.php"
    assert_equal ":html", body
    get "/test.php.json"
    assert_equal ":json", body
  end

  should "correctly accept priority of format" do
    mock_app do
      get "test.php", :provides => [:html, :json, :xml] do
        content_type.inspect
      end
    end

    get "/test.php"
    assert_equal ":html", body
    get "/test.php", {}, { 'HTTP_ACCEPT' => 'application/xml' }
    assert_equal ":xml", body
    get "/test.php?format=json", { 'HTTP_ACCEPT' => 'application/xml' }
    assert_equal ":json", body
    get "/test.php.json?format=html", { 'HTTP_ACCEPT' => 'application/xml' }
    assert_equal ":json", body
  end

  should "generate routes for format with controller" do
    mock_app do
      controller :posts do
        get(:index, :provides => [:html, :rss, :atom, :js]) { render :haml, "Index.#{content_type}" }
        get(:show,  :with => :id, :provides => [:html, :rss, :atom]) { render :haml, "Show.#{content_type}" }
      end
    end
    get "/posts"
    assert_equal "Index.html\n", body
    get "/posts.rss"
    assert_equal "Index.rss\n", body
    get "/posts.atom"
    assert_equal "Index.atom\n", body
    get "/posts.js"
    assert_equal "Index.js\n", body
    get "/posts/show/5"
    assert_equal "Show.html\n", body
    get "/posts/show/5.rss"
    assert_equal "Show.rss\n", body
    get "/posts/show/10.atom"
    assert_equal "Show.atom\n", body
  end

  should 'map routes' do
    mock_app do
      get(:bar){ "bar" }
    end
    get "/bar"
    assert_equal "bar", body
    assert_equal "/bar", @app.url(:bar)
  end

  should 'remove index from path' do
    mock_app do
      get(:index){ "index" }
      get("/accounts/index"){ "accounts" }
    end
    get "/"
    assert_equal "index", body
    assert_equal "/", @app.url(:index)
    get "/accounts/index"
    assert_equal "accounts", body
  end

  should 'remove index from path with params' do
    mock_app do
      get(:index, :with => :name){ "index with #{params[:name]}" }
    end
    get "/bobby"
    assert_equal "index with bobby", body
    assert_equal "/john", @app.url(:index, :name => "john")
  end

  should 'parse named params' do
    mock_app do
      get(:print, :with => :id){ "Im #{params[:id]}" }
    end
    get "/print/9"
    assert_equal "Im 9", body
    assert_equal "/print/9", @app.url(:print, :id => 9)
  end

  should '405 on wrong request_method' do
    mock_app do
      post('/bar'){ "bar" }
    end
    get "/bar"
    assert_equal 405, status
  end

  should 'respond to' do
    mock_app do
      get(:a, :provides => :js){ "js" }
      get(:b, :provides => :any){ "any" }
      get(:c, :provides => [:js, :json]){ "js,json" }
      get(:d, :provides => [:html, :js]){ "html,js"}
    end
    get "/a"
    assert_equal 200, status
    assert_equal "js", body
    get "/a.js"
    assert_equal "js", body
    get "/b"
    assert_equal "any", body
    # TODO randomly fails in minitest :(
    # assert_raises(RuntimeError) { get "/b.foo" }
    get "/c"
    assert_equal 200, status
    assert_equal "js,json", body
    get "/c.js"
    assert_equal "js,json", body
    get "/c.json"
    assert_equal "js,json", body
    get "/d"
    assert_equal "html,js", body
    get "/d.js"
    assert_equal "html,js", body
  end

  should 'respond_to and set content_type' do
    Rack::Mime::MIME_TYPES['.foo'] = 'application/foo'
    mock_app do
      get :a, :provides => :any do
        case content_type
          when :js    then "js"
          when :json  then "json"
          when :foo   then "foo"
          when :html  then "html"
        end
      end
    end
    get "/a.js"
    assert_equal "js", body
    assert_equal 'application/javascript;charset=utf-8', response["Content-Type"]
    get "/a.json"
    assert_equal "json", body
    assert_equal 'application/json;charset=utf-8', response["Content-Type"]
    get "/a.foo"
    assert_equal "foo", body
    assert_equal 'application/foo;charset=utf-8', response["Content-Type"]
    get "/a"
    assert_equal "html", body
    assert_equal 'text/html;charset=utf-8', response["Content-Type"]
  end

  should 'use controllers' do
    mock_app do
      controller "/admin" do
        get("/"){ "index" }
        get("/show/:id"){ "show #{params[:id]}" }
      end
    end
    get "/admin"
    assert_equal "index", body
    get "/admin/show/1"
    assert_equal "show 1", body
  end

  should 'use named controllers' do
    mock_app do
      controller :admin do
        get(:index, :with => :id){ params[:id] }
        get(:show, :with => :id){ "show #{params[:id]}" }
      end
      controllers :foo, :bar do
        get(:index){ "foo_bar_index" }
      end
    end
    get "/admin/1"
    assert_equal "1", body
    get "/admin/show/1"
    assert_equal "show 1", body
    assert_equal "/admin/1", @app.url(:admin_index, :id => 1)
    assert_equal "/admin/show/1", @app.url(:admin_show, :id => 1)
    get "/foo/bar"
    assert_equal "foo_bar_index", body
  end

  should 'use map and with' do
    mock_app do
      get :index, :map => '/bugs', :with => :id do
        params[:id]
      end
    end
    get '/bugs/4'
    assert_equal '4', body
    assert_equal "/bugs/4", @app.url(:index, :id => 4)
  end

  should "ignore trailing delimiters within a named controller" do
    mock_app do
      controller :posts do
        get(:index, :provides => [:html, :js]){ "index" }
        get(:new)  { "new" }
        get(:show, :with => :id){ "show #{params[:id]}" }
      end
    end
    get "/posts"
    assert_equal "index", body
    get "/posts/"
    assert_equal "index", body
    get "/posts.js"
    assert_equal "index", body
    get "/posts.js/"
    assert_equal "index", body
    get "/posts/new"
    assert_equal "new", body
    get "/posts/new/"
    assert_equal "new", body
  end

  should "ignore trailing delimiters within a named controller for unnamed actions" do
    mock_app do
      controller :accounts do
        get("/") { "account_index" }
        get("/new") { "new" }
      end
      controller :votes do
        get("/") { "vote_index" }
      end
    end
    get "/accounts"
    assert_equal "account_index", body
    get "/accounts/"
    assert_equal "account_index", body
    get "/accounts/new"
    assert_equal "new", body
    get "/accounts/new/"
    assert_equal "new", body
    get "/votes"
    assert_equal "vote_index", body
    get "/votes/"
    assert_equal "vote_index", body
  end

  should 'use named controllers with array routes' do
    mock_app do
      controller :admin do
        get(:index){ "index" }
        get(:show, :with => :id){ "show #{params[:id]}" }
      end
      controllers :foo, :bar do
        get(:index){ "foo_bar_index" }
      end
    end
    get "/admin"
    assert_equal "index", body
    get "/admin/show/1"
    assert_equal "show 1", body
    assert_equal "/admin", @app.url(:admin, :index)
    assert_equal "/admin/show/1", @app.url(:admin, :show, :id => 1)
    get "/foo/bar"
    assert_equal "foo_bar_index", body
  end

  should "support a reindex action and remove index inside controller" do
    mock_app do
      controller :posts do
        get(:index){ "index" }
        get(:reindex){ "reindex" }
      end
    end
    get "/posts"
    assert_equal "index", body
    get "/posts/reindex"
    assert_equal "/posts/reindex", @app.url(:posts, :reindex)
    assert_equal "reindex", body
  end

  should 'use uri_root' do
    mock_app do
      get(:foo){ "foo" }
    end
    @app.uri_root = '/'
    assert_equal "/foo", @app.url(:foo)
    @app.uri_root = '/testing'
    assert_equal "/testing/foo", @app.url(:foo)
    @app.uri_root = '/testing/'
    assert_equal "/testing/foo", @app.url(:foo)
    @app.uri_root = 'testing/bar///'
    assert_equal "/testing/bar/foo", @app.url(:foo)
  end

  should 'use uri_root with controllers' do
    mock_app do
      controller :foo do
        get(:bar){ "bar" }
      end
    end
    @app.uri_root = '/testing'
    assert_equal "/testing/foo/bar", @app.url(:foo, :bar)
  end

  should 'use RACK_BASE_URI' do
    mock_app do
      get(:foo){ "foo" }
    end
    # Wish there was a side-effect free way to test this...
    ENV['RACK_BASE_URI'] = '/'
    assert_equal "/foo", @app.url(:foo)
    ENV['RACK_BASE_URI'] = '/testing'
    assert_equal "/testing/foo", @app.url(:foo)
    ENV['RACK_BASE_URI'] = nil
  end

  should 'reset routes' do
    mock_app do
      get("/"){ "foo" }
      reset_router!
    end
    get "/"
    assert_equal 404, status
  end

  should 'respect priorities' do
    route_order = []
    mock_app do
      get(:index, :priority => :normal) { route_order << :normal; pass }
      get(:index, :priority => :low)  { route_order << :low; "hello" }
      get(:index, :priority => :high)  { route_order << :high; pass }
    end
    get '/'
    assert_equal [:high, :normal, :low], route_order
    assert_equal "hello", body
  end

  should 'allow optionals' do
    mock_app do
      get(:show, :map => "/stories/:type(/:category)") do
        "#{params[:type]}/#{params[:category]}"
      end
    end
    get "/stories/foo"
    assert_equal "foo/", body
    get "/stories/foo/bar"
    assert_equal "foo/bar", body
  end

  should 'apply maps' do
    mock_app do
      controllers :admin do
        get(:index, :map => "/"){ "index" }
        get(:show, :with => :id, :map => "/show"){ "show #{params[:id]}" }
        get(:edit, :map => "/edit/:id/product"){ "edit #{params[:id]}" }
        get(:wacky, :map => "/wacky-:id-:product_id"){ "wacky #{params[:id]}-#{params[:product_id]}" }
      end
    end
    get "/"
    assert_equal "index", body
    get @app.url(:admin, :index)
    assert_equal "index", body
    get "/show/1"
    assert_equal "show 1", body
    get "/edit/1/product"
    assert_equal "edit 1", body
    get "/wacky-1-2"
    assert_equal "wacky 1-2", body
  end

  should 'apply maps when given path is kind of hash' do
    mock_app do
      controllers :admin do
        get(:foobar, "/foo/bar"){ "foobar" }
      end
    end
    get "/foo/bar"
    assert_equal "foobar", body
  end

  should "apply parent to route" do
    mock_app do
      controllers :project do
        get(:index, :parent => :user) { "index #{params[:user_id]}" }
        get(:index, :parent => [:user, :section]) { "index #{params[:user_id]} #{params[:section_id]}" }
        get(:edit, :with => :id, :parent => :user) { "edit #{params[:id]} #{params[:user_id]}"}
        get(:show, :with => :id, :parent => [:user, :product]) { "show #{params[:id]} #{params[:user_id]} #{params[:product_id]}"}
      end
    end
    get "/user/1/project"
    assert_equal "index 1", body
    get "/user/1/section/3/project"
    assert_equal "index 1 3", body
    get "/user/1/project/edit/2"
    assert_equal "edit 2 1", body
    get "/user/1/product/2/project/show/3"
    assert_equal "show 3 1 2", body
  end

  should "apply parent to controller" do
    mock_app do
      controller :project, :parent => :user do
        get(:index) { "index #{params[:user_id]}"}
        get(:edit, :with => :id, :parent => :user) { "edit #{params[:id]} #{params[:user_id]}"}
        get(:show, :with => :id, :parent => :product) { "show #{params[:id]} #{params[:user_id]} #{params[:product_id]}"}
      end
    end

    user_project_url = "/user/1/project"
    get user_project_url
    assert_equal "index 1", body
    assert_equal user_project_url, @app.url(:project, :index, :user_id => 1)

    user_project_edit_url = "/user/1/project/edit/2"
    get user_project_edit_url
    assert_equal "edit 2 1", body
    assert_equal user_project_edit_url, @app.url(:project, :edit, :user_id => 1, :id => 2)

    user_product_project_url = "/user/1/product/2/project/show/3"
    get user_product_project_url
    assert_equal "show 3 1 2", body
    assert_equal user_product_project_url, @app.url(:project, :show, :user_id => 1, :product_id => 2, :id => 3)
  end

  should "apply parent with shallowing to controller" do
    mock_app do
      controller :project do
        parent :user
        parent :shop, :optional => true
        get(:index) { "index #{params[:user_id]} #{params[:shop_id]}" }
        get(:edit, :with => :id) { "edit #{params[:id]} #{params[:user_id]} #{params[:shop_id]}" }
        get(:show, :with => :id, :parent => :product) { "show #{params[:id]} #{params[:user_id]} #{params[:product_id]} #{params[:shop_id]}" }
      end
    end

    assert_equal "/user/1/project", @app.url(:project, :index, :user_id => 1, :shop_id => nil)
    assert_equal "/user/1/shop/23/project", @app.url(:project, :index, :user_id => 1, :shop_id => 23)

    user_project_url = "/user/1/project"
    get user_project_url
    assert_equal "index 1 ", body
    assert_equal user_project_url, @app.url(:project, :index, :user_id => 1)

    user_project_edit_url = "/user/1/project/edit/2"
    get user_project_edit_url
    assert_equal "edit 2 1 ", body
    assert_equal user_project_edit_url, @app.url(:project, :edit, :user_id => 1, :id => 2)

    user_product_project_url = "/user/1/product/2/project/show/3"
    get user_product_project_url
    assert_equal "show 3 1 2 ", body
    assert_equal user_product_project_url, @app.url(:project, :show, :user_id => 1, :product_id => 2, :id => 3)

    user_project_url = "/user/1/shop/1/project"
    get user_project_url
    assert_equal "index 1 1", body
    assert_equal user_project_url, @app.url(:project, :index, :user_id => 1, :shop_id => 1)

    user_project_edit_url = "/user/1/shop/1/project/edit/2"
    get user_project_edit_url
    assert_equal "edit 2 1 1", body
    assert_equal user_project_edit_url, @app.url(:project, :edit, :user_id => 1, :id => 2, :shop_id => 1)

    user_product_project_url = "/user/1/shop/1/product/2/project/show/3"
    get user_product_project_url
    assert_equal "show 3 1 2 1", body
    assert_equal user_product_project_url, @app.url(:project, :show, :user_id => 1, :product_id => 2, :id => 3, :shop_id => 1)
  end

  should "respect map in parents with shallowing" do
    mock_app do
      controller :project do
        parent :shop, :map => "/foo/bar"
        get(:index) { "index #{params[:shop_id]}" }
      end
    end

    shop_project_url = "/foo/bar/1/project"
    get shop_project_url
    assert_equal "index 1", body
    assert_equal shop_project_url, @app.url(:project, :index, :shop_id => 1)
  end

  should "use default values" do
    mock_app do
      controller :lang => :it do
        get(:index, :map => "/:lang") { "lang is #{params[:lang]}" }
      end
      # This is only for be sure that default values
      # work only for the given controller
      get(:foo, :map => "/foo") {}
    end
    assert_equal "/it",  @app.url(:index)
    assert_equal "/foo", @app.url(:foo)
    get "/en"
    assert_equal "lang is en", body
  end

  should "transitions to the next matching route on pass" do
    mock_app do
      get '/:foo' do
        pass
        'Hello Foo'
      end
      get '/:bar' do
        'Hello World'
      end
    end

    get '/za'
    assert_equal 'Hello World', body
  end

  should "filters by accept header" do
    mock_app do
      get '/foo', :provides => [:xml, :js] do
        request.env['HTTP_ACCEPT']
      end
    end

    get '/foo', {}, { 'HTTP_ACCEPT' => 'application/xml' }
    assert ok?
    assert_equal 'application/xml', body
    assert_equal 'application/xml;charset=utf-8', response.headers['Content-Type']

    get '/foo.xml'
    assert ok?
    assert_equal 'application/xml;charset=utf-8', response.headers['Content-Type']

    get '/foo', {}, { 'HTTP_ACCEPT' => 'application/javascript' }
    assert ok?
    assert_equal 'application/javascript', body
    assert_equal 'application/javascript;charset=utf-8', response.headers['Content-Type']

    get '/foo.js'
    assert ok?
    assert_equal 'application/javascript;charset=utf-8', response.headers['Content-Type']

    get '/foo', {}, { "HTTP_ACCEPT" => 'text/html' }
    assert_equal 406, status
  end

  should "does not allow global provides" do
    mock_app do
      provides :xml

      get("/foo"){ "Foo in #{content_type}" }
      get("/bar"){ "Bar in #{content_type}" }
    end

    get '/foo', {}, { 'HTTP_ACCEPT' => 'application/xml' }
    assert_equal 'Foo in xml', body
    get '/foo'
    assert_equal 'Foo in xml', body

    get '/bar', {}, { 'HTTP_ACCEPT' => 'application/xml' }
    assert_equal 'Bar in html', body
  end

  should "does not allow global provides in controller" do
    mock_app do
      controller :base do
        provides :xml

        get(:foo, "/foo"){ "Foo in #{content_type}" }
        get(:bar, "/bar"){ "Bar in #{content_type}" }
      end
    end

    get '/foo', {}, { 'HTTP_ACCEPT' => 'application/xml' }
    assert_equal 'Foo in xml', body
    get '/foo'
    assert_equal 'Foo in xml', body

    get '/bar', {}, { 'HTTP_ACCEPT' => 'application/xml' }
    assert_equal 'Bar in html', body
  end

  should "map non named routes in controllers" do
    mock_app do
      controller :base do
        get("/foo") { "ok" }
        get("/bar") { "ok" }
      end
    end

    get "/base/foo"
    assert ok?
    get "/base/bar"
    assert ok?
  end

  should "set content_type to :html for both empty Accept as well as Accept text/html" do
    mock_app do
      provides :html

      get("/foo"){ content_type.to_s }
    end

    get '/foo', {}, {}
    assert_equal 'html', body

    get '/foo', {}, { 'HTTP_ACCEPT' => 'text/html' }
    assert_equal 'html', body
  end

  should "set content_type to :html if Accept */*" do
    mock_app do
      get("/foo", :provides => [:html, :js]) { content_type.to_s }
    end
    get '/foo', {}, {}
    assert_equal 'html', body

    get '/foo', {}, { 'HTTP_ACCEPT' => '*/*;q=0.5' }
    assert_equal 'html', body
  end

  should "set content_type to :js if Accept includes both application/javascript and */*;q=0.5" do
    mock_app do
      get("/foo", :provides => [:html, :js]) { content_type.to_s }
    end
    get '/foo', {}, { 'HTTP_ACCEPT' => 'application/javascript, */*;q=0.5' }
    assert_equal 'js', body
  end

  should 'allows custom route-conditions to be set via route options and halt' do
    protector = Module.new do
      def protect(*args)
        condition {
          unless authorize(params["user"], params["password"])
            halt 403, "go away"
          end
        }
      end
    end

    mock_app do
      register protector

      helpers do
        def authorize(username, password)
          username == "foo" && password == "bar"
        end
      end

      get "/", :protect => true do
        "hey"
      end
    end

    get "/"
    assert forbidden?
    assert_equal "go away", body

    get "/", :user => "foo", :password => "bar"
    assert ok?
    assert_equal "hey", body
  end

  should 'allows custom route-conditions to be set via route options using two routes' do
    protector = Module.new do
      def protect(*args)
        condition { authorize(params["user"], params["password"]) }
      end
    end

    mock_app do
      register protector

      helpers do
        def authorize(username, password)
          username == "foo" && password == "bar"
        end
      end

      get "/", :protect => true do
        "hey"
      end

      get "/" do
        "go away"
      end
    end

    get "/"
    assert_equal "go away", body

    get "/", :user => "foo", :password => "bar"
    assert ok?
    assert_equal "hey", body
  end

  should "allow concise routing" do
    mock_app do
      get :index, ":id" do
        params[:id]
      end

      get :map, "route/:id" do
        params[:id]
      end
    end

    get "/123"
    assert_equal "123", body

    get "/route/123"
    assert_equal "123", body
  end

  should "support halting with 404 and message" do
    mock_app do
      controller do
        get :index do
          halt 404, "not found"
        end
      end
    end

    get "/"
    assert_equal 404, status
    assert_equal "not found", body
  end

  should "allow passing & halting in before filters" do
    mock_app do
      controller do
        before { env['QUERY_STRING'] == 'secret' or pass }
        get :index do
          "secret index"
        end
      end

      controller do
        before { env['QUERY_STRING'] == 'halt' and halt 401, 'go away!' }
        get :index do
          "index"
        end
      end
    end

    get "/?secret"
    assert_equal "secret index", body

    get "/?halt"
    assert_equal "go away!", body
    assert_equal 401, status

    get "/"
    assert_equal "index", body
  end

  should 'scope filters in the given controller' do
    mock_app do
      before { @global = 'global' }
      after { @global = nil }

      controller :foo do
        before { @foo = :foo }
        after { @foo = nil }
        get("/") { [@foo, @bar, @global].compact.join(" ") }
      end

      get("/") { [@foo, @bar, @global].compact.join(" ") }

      controller :bar do
        before { @bar = :bar }
        after { @bar = nil }
        get("/") { [@foo, @bar, @global].compact.join(" ") }
      end
    end

    get "/bar"
    assert_equal "bar global", body

    get "/foo"
    assert_equal "foo global", body

    get "/"
    assert_equal "global", body
  end

  should 'works with optionals params' do
    mock_app do
      get("/foo(/:bar)") { params[:bar] }
    end

    get "/foo/bar"
    assert_equal "bar", body

    get "/foo"
    assert_equal "", body
  end

  should 'work with multiple dashed params' do
    mock_app do
      get "/route/:foo/:bar/:baz", :provides => :html do
        "#{params[:foo]};#{params[:bar]};#{params[:baz]}"
      end
    end

    get "/route/foo/bar/baz"
    assert_equal 'foo;bar;baz', body

    get "/route/foo/bar-whatever/baz"
    assert_equal 'foo;bar-whatever;baz', body
  end

  should 'work with arbitrary params' do
    mock_app do
      get(:testing) { params[:foo] }
    end

    url = @app.url(:testing, :foo => 'bar')
    assert_equal "/testing?foo=bar", url
    get url
    assert_equal "bar", body
  end

  should 'ignore nil params' do
    mock_app do
      get(:testing, :provides => [:html, :json]) do
      end
    end
    assert_equal '/testing.html', @app.url(:testing, :format => :html)
    assert_equal '/testing', @app.url(:testing, :format => nil)
  end

  should 'be able to access params in a before filter' do
    username_from_before_filter = nil

    mock_app do
      before do
        username_from_before_filter = params[:username]
      end

      get :users, :with => :username do
      end
    end
    get '/users/josh'
    assert_equal 'josh', username_from_before_filter
  end

  should "be able to access params normally when a before filter is specified" do
    mock_app do
      before { }
      get :index do
        params.inspect
      end
    end
    get '/?test=what'
    assert_equal '{"test"=>"what"}', body
  end

  should 'work with controller and arbitrary params' do
    mock_app do
      get(:testing) { params[:foo] }
      controller :test1 do
        get(:url1) { params[:foo] }
        get(:url2, :provides => [:html, :json]) { params[:foo] }
      end
    end

    url = @app.url(:test1, :url1, :foo => 'bar1')
    assert_equal "/test1/url1?foo=bar1", url
    get url
    assert_equal "bar1", body

    url = @app.url(:test1, :url2, :foo => 'bar2')
    assert_equal "/test1/url2?foo=bar2", url
    get url
    assert_equal "bar2", body
  end

  should "parse two routes with the same path but different http verbs" do
    mock_app do
      get(:index) { "This is the get index" }
      post(:index) { "This is the post index" }
    end
    get "/"
    assert_equal "This is the get index", body
    post "/"
    assert_equal "This is the post index", body
  end

  should "use optionals params" do
    mock_app do
      get(:index, :map => "/(:foo(/:bar))") { "#{params[:foo]}-#{params[:bar]}" }
    end
    get "/foo"
    assert_equal "foo-", body
    get "/foo/bar"
    assert_equal "foo-bar", body
  end

  should "parse two routes with the same path but different http verbs and provides" do
    mock_app do
      get(:index, :provides => [:html, :json]) { "This is the get index.#{content_type}" }
      post(:index, :provides => [:html, :json]) { "This is the post index.#{content_type}" }
    end
    get "/"
    assert_equal "This is the get index.html", body
    post "/"
    assert_equal "This is the post index.html", body
    get "/.json"
    assert_equal "This is the get index.json", body
    get "/.js"
    assert_equal 405, status
    post "/.json"
    assert_equal "This is the post index.json", body
    post "/.js"
    assert_equal 405, status
  end

  should "allow controller level mapping" do
    mock_app do
      controller :map => "controller-:id" do
        get(:url3) { "#{params[:id]}" }
        get(:url4, :map => 'test-:id2') { "#{params[:id]}, #{params[:id2]}" }
      end
    end

    url = @app.url(:url3, :id => 1)
    assert_equal "/controller-1/url3", url
    get url
    assert_equal "1", body

    url = @app.url(:url4, 1, 2)
    assert_equal "/controller-1/test-2", url
    get url
    assert_equal "1, 2", body
  end

  should 'use absolute and relative maps' do
    mock_app do
      controller :one do
        parent :three
        get :index, :map => 'one' do; end
        get :index2, :map => '/one' do; end
      end

      controller :two, :map => 'two' do
        parent :three
        get :index, :map => 'two' do; end
        get :index2, :map => '/two', :with => :id do; end
      end
    end
    assert_equal "/three/three_id/one", @app.url(:one, :index, 'three_id')
    assert_equal "/one", @app.url(:one, :index2)
    assert_equal "/two/three/three_id/two", @app.url(:two, :index, 'three_id')
    assert_equal "/two/four_id", @app.url(:two, :index2, 'four_id')
  end

  should "work with params and parent options" do
    mock_app do
      controller :test2, :parent => :parent1, :parent1_id => 1 do
        get(:url3) { params[:foo] }
        get(:url4, :with => :with1) { params[:foo] }
        get(:url5, :with => :with2, :provides => [:html]) { params[:foo] }
      end
    end

    url = @app.url(:test2, :url3, :foo => 'bar3')
    assert_equal "/parent1/1/test2/url3?foo=bar3", url
    get url
    assert_equal "bar3", body

    url = @app.url(:test2, :url4, :with1 => 'awith1', :foo => 'bar4')
    assert_equal "/parent1/1/test2/url4/awith1?foo=bar4", url
    get url
    assert_equal "bar4", body

    url = @app.url(:test2, :url5, :with2 => 'awith1', :foo => 'bar5')
    assert_equal "/parent1/1/test2/url5/awith1?foo=bar5", url
    get url
    assert_equal "bar5", body
  end

  should "parse params without explicit provides for every matching route" do
    mock_app do
      get(:index, :map => "/foos/:bar") { "get bar = #{params[:bar]}" }
      post :create, :map => "/foos/:bar", :provides => [:html, :js] do
        "post bar = #{params[:bar]}"
      end
    end

    get "/foos/hello"
    assert_equal "get bar = hello", body
    post "/foos/hello"
    assert_equal "post bar = hello", body
    post "/foos/hello.js"
    assert_equal "post bar = hello", body
  end

  should "properly route to first foo with two similar routes" do
    mock_app do
      controllers do
        get('/foo/') { "this is foo" }
        get(:show, :map => "/foo/:bar/:id") { "/foo/#{params[:bar]}/#{params[:id]}" }
      end
    end
    get "/foo"
    assert_equal "this is foo", body
    get "/foo/"
    assert_equal "this is foo", body
    get '/foo/5/10'
    assert_equal "/foo/5/10", body
  end

  should "index routes should be optional when nested" do
    mock_app do
      controller '/users', :provides => [:json] do
        get '/' do
          "foo"
        end
      end
    end
    get "/users.json"
    assert_equal "foo", body
  end

  should "use provides as conditional" do
    mock_app do
      provides :json
      get "/" do
        "foo"
      end
    end
    get "/.json"
    assert_equal "foo", body
  end

  should_eventually "reset provides for routes that didn't use it" do
    mock_app do
      get('/foo', :provides => :js){}
      get('/bar'){}
    end
    get '/foo'
    assert ok?
    get '/foo.js'
    assert ok?
    get '/bar'
    assert ok?
    get '/bar.js'
    assert_equal 404, status
  end

  should "pass controller conditions to each route" do
    counter = 0

    mock_app do
      self.class.send(:define_method, :increment!) do |*args|
        condition { counter += 1 }
      end

      controller :posts, :conditions => {:increment! => true} do
        get("/foo") { "foo" }
        get("/bar") { "bar" }
      end

    end

    get "/posts/foo"
    get "/posts/bar"
    assert_equal 2, counter
  end

  should "allow controller conditions to be overridden" do
    counter = 0

    mock_app do
      self.class.send(:define_method, :increment!) do |increment|
        condition { counter += 1 } if increment
      end

      controller :posts, :conditions => {:increment! => true} do
        get("/foo") { "foo" }
        get("/bar", :increment! => false) { "bar" }
      end

    end

    get "/posts/foo"
    get "/posts/bar"
    assert_equal 1, counter
  end

  should "parse params with class level provides" do
    mock_app do
      controllers :posts, :provides => [:html, :js] do
        post(:create, :map => "/foo/:bar/:baz/:id") {
          "POST CREATE #{params[:bar]} - #{params[:baz]} - #{params[:id]}"
        }
      end
      controllers :topics, :provides => [:js, :html] do
        get(:show, :map => "/foo/:bar/:baz/:id") { render "topics/show" }
        post(:create, :map => "/foo/:bar/:baz") { "TOPICS CREATE #{params[:bar]} - #{params[:baz]}" }
      end
    end
    post "/foo/bar/baz.js"
    assert_equal "TOPICS CREATE bar - baz", body, "should parse params with explicit .js"
    post @app.url(:topics, :create, :format => :js, :bar => 'bar', :baz => 'baz')
    assert_equal "TOPICS CREATE bar - baz", body, "should parse params from generated url"
    post "/foo/bar/baz/5.js"
    assert_equal "POST CREATE bar - baz - 5", body
    post @app.url(:posts, :create, :format => :js, :bar => 'bar', :baz => 'baz', :id => 5)
    assert_equal "POST CREATE bar - baz - 5", body
  end

  should "parse params properly with inline provides" do
    mock_app do
      controllers :posts do
        post(:create, :map => "/foo/:bar/:baz/:id", :provides => [:html, :js]) {
          "POST CREATE #{params[:bar]} - #{params[:baz]} - #{params[:id]}"
        }
      end
      controllers :topics do
        get(:show, :map => "/foo/:bar/:baz/:id", :provides => [:html, :js]) { render "topics/show" }
        post(:create, :map => "/foo/:bar/:baz", :provides => [:html, :js]) { "TOPICS CREATE #{params[:bar]} - #{params[:baz]}" }
      end
    end
    post @app.url(:topics, :create, :format => :js, :bar => 'bar', :baz => 'baz')
    assert_equal "TOPICS CREATE bar - baz", body, "should properly post to topics create action"
    post @app.url(:posts, :create, :format => :js, :bar => 'bar', :baz => 'baz', :id => 5)
    assert_equal "POST CREATE bar - baz - 5", body, "should properly post to create action"
  end

  should "have overideable format" do
    mock_app do
      ::Rack::Mime::MIME_TYPES[".other"] = "text/html"
      before do
        params[:format] ||= :other
      end
      get("/format_test", :provides => [:html, :other]){ content_type.to_s }
    end
    get "/format_test"
    assert_equal "other", body
  end

  should 'invokes handlers registered with ::error when raised' do
    mock_app do
      set :raise_errors, false
      error(FooError) { 'Foo!' }
      get '/' do
        raise FooError
      end
    end
    get '/'
    assert_equal 500, status
    assert_equal 'Foo!', body
  end

  should 'have MethodOverride middleware' do
    mock_app do
      put('/') { 'okay' }
    end
    assert @app.method_override?
    post '/', {'_method'=>'PUT'}, {}
    assert_equal 200, status
    assert_equal 'okay', body
  end

  should 'return value from params' do
    mock_app do
      get("/foo/:bar"){ raise "'bar' should be a string" unless params[:bar].kind_of? String}
    end
    get "/foo/50"
    assert ok?
  end

  should 'have MethodOverride middleware with more options' do
    mock_app do
      put('/hi', :provides => [:json]) { 'hi' }
    end
    post '/hi', {'_method'=>'PUT'}
    assert_equal 200, status
    assert_equal 'hi', body
    post '/hi.json', {'_method'=>'PUT'}
    assert_equal 200, status
    assert_equal 'hi', body
    post '/hi.json'
    assert_equal 405, status
  end

  should 'parse nested params' do
    mock_app do
      get(:index) { "%s %s" % [params[:account][:name], params[:account][:surname]] }
    end
    get "/?account[name]=foo&account[surname]=bar"
    assert_equal 'foo bar', body
    get @app.url(:index, "account[name]" => "foo", "account[surname]" => "bar")
    assert_equal 'foo bar', body
  end

  should 'render sinatra NotFound page' do
    mock_app { set :environment, :development }
    get "/"
    assert_equal 404, status
    assert_match %r{(Sinatra doesn&rsquo;t know this ditty.|<h1>Not Found</h1>)}, body
  end

  should 'render a custom NotFound page' do
    mock_app do
      error(Sinatra::NotFound) { "not found" }
    end
    get "/"
    assert_equal 404, status
    assert_match /not found/, body
  end

  should 'render a custom 404 page' do
    mock_app do
      error(404) { "not found" }
    end
    get "/"
    assert_equal 404, status
    assert_match /not found/, body
  end

  should 'recognize paths' do
    mock_app do
      controller :foo do
        get(:bar, :map => "/my/:id/custom-route") { }
      end
      get(:simple, :map => "/simple/:id") { }
      get(:with_format, :with => :id, :provides => :js) { }
    end
    assert_equal [:foo_bar, { :id => "fantastic" }], @app.recognize_path(@app.url(:foo, :bar, :id => :fantastic))
    assert_equal [:foo_bar, { :id => "18" }], @app.recognize_path(@app.url(:foo, :bar, :id => 18))
    assert_equal [:simple, { :id => "bar" }], @app.recognize_path(@app.url(:simple, :id => "bar"))
    assert_equal [:simple, { :id => "true" }], @app.recognize_path(@app.url(:simple, :id => true))
    assert_equal [:simple, { :id => "9" }], @app.recognize_path(@app.url(:simple, :id => 9))
    assert_equal [:with_format, { :id => "bar", :format => "js" }], @app.recognize_path(@app.url(:with_format, :id => "bar", :format => :js))
    assert_equal [:with_format, { :id => "true", :format => "js" }], @app.recognize_path(@app.url(:with_format, :id => true, :format => "js"))
    assert_equal [:with_format, { :id => "9", :format => "js" }], @app.recognize_path(@app.url(:with_format, :id => 9, :format => :js))
  end

  should 'have current_path' do
    mock_app do
      controller :foo do
        get(:index) { current_path }
        get :bar, :map => "/paginate/:page" do
          current_path
        end
        get(:after) { current_path }
      end
    end
    get "/paginate/10"
    assert_equal "/paginate/10", body
    get "/foo/after"
    assert_equal "/foo/after", body
    get "/foo"
    assert_equal "/foo", body
  end

  should 'accept :map and :parent' do
    mock_app do
      controller :posts do
        get :show, :parent => :users, :map => "posts/:id" do
          "#{params[:user_id]}-#{params[:id]}"
        end
      end
    end
    get '/users/123/posts/321'
    assert_equal "123-321", body
  end

  should 'change params in current_path' do
    mock_app do
      get :index, :map => "/paginate/:page" do
        current_path(:page => 66)
      end
    end
    get @app.url(:index, :page => 10)
    assert_equal "/paginate/66", body
  end
end
