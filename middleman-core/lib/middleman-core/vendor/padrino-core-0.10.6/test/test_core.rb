require File.expand_path(File.dirname(__FILE__) + '/helper')

describe "Core" do
  def setup
    Padrino.clear!
  end

  context 'for core functionality' do

    should 'check some global methods' do
      assert_respond_to Padrino, :root
      assert_respond_to Padrino, :env
      assert_respond_to Padrino, :application
      assert_respond_to Padrino, :set_encoding
      assert_respond_to Padrino, :load!
      assert_respond_to Padrino, :reload!
      assert_respond_to Padrino, :version
      assert_respond_to Padrino, :configure_apps
    end


    should 'validate global helpers' do
      assert_equal :test, Padrino.env
      assert_match /\/test/, Padrino.root
      assert_not_nil Padrino.version
    end

    should 'set correct utf-8 encoding' do
      Padrino.set_encoding
      if RUBY_VERSION <'1.9'
        assert_equal 'UTF8', $KCODE
      else
        assert_equal Encoding.default_external, Encoding::UTF_8
        assert_equal Encoding.default_internal, Encoding::UTF_8
      end
    end

    should 'have load paths' do
      assert_equal [Padrino.root('lib'), Padrino.root('models'), Padrino.root('shared')], Padrino.load_paths
    end

    should 'raise application error if I instantiate a new padrino application without mounted apps' do
      assert_raises(Padrino::ApplicationLoadError) { Padrino.application.new }
    end

    should "check before/after padrino load hooks" do
      Padrino.before_load { @_foo  = 1 }
      Padrino.after_load  { @_foo += 1 }
      Padrino.load!
      assert_equal 1, Padrino.before_load.size
      assert_equal 1, Padrino.after_load.size
      assert_equal 2, @_foo
    end

    should "add middlewares in front if specified" do
      test = Class.new {
        def initialize(app)
          @app = app
        end

        def call(env)
          status, headers, body = @app.call(env)
          headers["Middleware-Called"] = "yes"
          return status, headers, body
        end
      }

      class Foo < Padrino::Application; end

      Padrino.use(test)
      Padrino.mount(Foo).to("/")

      res = Rack::MockRequest.new(Padrino.application).get("/")
      assert_equal "yes", res["Middleware-Called"]
    end
  end
end
