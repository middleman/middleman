require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/apps/simple')

describe "SimpleReloader" do

  context 'for simple reset functionality' do

    should 'reset routes' do
      mock_app do
        (1..10).each do |i|
          get("/#{i}") { "Foo #{i}" }
        end
      end
      (1..10).each do |i|
        get "/#{i}"
        assert_equal "Foo #{i}", body
      end
      @app.reset_routes!
      (1..10).each do |i|
        get "/#{i}"
        assert_equal 404, status
      end
    end

    should 'keep sinatra routes on development' do
      mock_app do
        set :environment, :development
        get("/"){ "ok" }
      end
      assert_equal :development, @app.environment
      get "/"
      assert_equal 200, status
      get "/__sinatra__/404.png"
      assert_equal 200, status
      assert_match /image\/png/, response["Content-Type"]
      @app.reset_routes!
      get "/"
      assert_equal 404, status
      get "/__sinatra__/404.png"
      assert_equal 200, status
      assert_match /image\/png/, response["Content-Type"]
    end
  end

  context 'for simple reload functionality' do

    should 'correctly instantiate SimpleDemo fixture' do
      Padrino.clear!
      Padrino.mount("simple_demo").to("/")
      assert_equal ["simple_demo"], Padrino.mounted_apps.map(&:name)
      assert SimpleDemo.reload?
      assert_match %r{fixtures/apps/simple.rb}, SimpleDemo.app_file
    end

    should_eventually 'correctly reload SimpleDemo fixture' do
      # TODO fix this test
      @app = SimpleDemo
      get "/"
      assert ok?
      new_phrase = "The magick number is: #{rand(2**255)}!"
      buffer     = File.read(SimpleDemo.app_file)
      new_buffer = buffer.gsub(/The magick number is: \d+!/, new_phrase)
      File.open(SimpleDemo.app_file, "w") { |f| f.write(new_buffer) }
      sleep 2 # We need at least a cooldown of 1 sec.
      get "/"
      assert_equal new_phrase, body

      # Now we need to prevent to commit a new changed file so we revert it
      File.open(SimpleDemo.app_file, "w") { |f| f.write(buffer) }
      Padrino.reload!
    end

    should 'correctly reset SimpleDemo fixture' do
      @app = SimpleDemo
      @app.reload!
      get "/rand"
      assert ok?
      last_body = body
      assert_equal 2, @app.filters[:before].size # one is ours the other is default_filter for content type
      assert_equal 1, @app.errors.size
      assert_equal 1, @app.filters[:after].size
      assert_equal 0, @app.middleware.size
      assert_equal 4, @app.routes.size # GET+HEAD of "/" + GET+HEAD of "/rand" = 4
      assert_equal 2, @app.extensions.size # [Padrino::Routing, Padrino::Rendering]
      assert_equal 0, @app.templates.size
      @app.reload!
      get "/rand"
      assert_not_equal last_body, body
      assert_equal 2, @app.filters[:before].size # one is ours the other is default_filter for content type
      assert_equal 1, @app.errors.size
      assert_equal 1, @app.filters[:after].size
      assert_equal 0, @app.middleware.size
      assert_equal 4, @app.routes.size # GET+HEAD of "/" = 2
      assert_equal 2, @app.extensions.size # [Padrino::Routing, Padrino::Rendering]
      assert_equal 0, @app.templates.size
    end
  end
end
