require File.expand_path(File.dirname(__FILE__) + '/helper')

class PadrinoPristine < Padrino::Application; end
class PadrinoTestApp < Padrino::Application; end
class PadrinoTestApp2 < Padrino::Application; end

describe "Application" do
  def setup
    Padrino.clear!
  end

  def teardown
    remove_views
  end

  context 'for application functionality' do

    should 'check default options' do
      assert File.identical?(__FILE__, PadrinoPristine.app_file)
      assert_equal :padrino_pristine, PadrinoPristine.app_name
      assert_equal :test, PadrinoPristine.environment
      assert_equal Padrino.root("views"), PadrinoPristine.views
      assert PadrinoPristine.raise_errors
      assert !PadrinoPristine.logging
      assert !PadrinoPristine.sessions
      assert !PadrinoPristine.dump_errors
      assert !PadrinoPristine.show_exceptions
      assert PadrinoPristine.raise_errors
      assert !Padrino.configure_apps
    end

    should 'check padrino specific options' do
      assert !PadrinoPristine.instance_variable_get(:@_configured)
      PadrinoPristine.send(:setup_application!)
      assert_equal :padrino_pristine, PadrinoPristine.app_name
      assert_equal 'StandardFormBuilder', PadrinoPristine.default_builder
      assert PadrinoPristine.instance_variable_get(:@_configured)
      assert !PadrinoPristine.reload?
      assert !PadrinoPristine.flash
    end

    should 'set global project settings' do
      Padrino.configure_apps { enable :sessions; set :foo, "bar" }
      PadrinoTestApp.send(:default_configuration!)
      PadrinoTestApp2.send(:default_configuration!)
      assert PadrinoTestApp.sessions, "should have sessions enabled"
      assert_equal "bar", PadrinoTestApp.settings.foo, "should have foo assigned"
      assert_equal PadrinoTestApp.session_secret, PadrinoTestApp2.session_secret
    end

    should "have shared sessions accessible in project" do
      Padrino.configure_apps { enable :sessions; set :session_secret, 'secret' }
      Padrino.mount("PadrinoTestApp").to("/write")
      Padrino.mount("PadrinoTestApp2").to("/read")
      PadrinoTestApp.tap { |app| app.send(:default_configuration!)
        app.get("/") { session[:foo] = "shared" } }
      PadrinoTestApp2.tap { |app| app.send(:default_configuration!)
        app.get("/") { session[:foo] } }
      browser = Rack::Test::Session.new(Rack::MockSession.new(Padrino.application))
      browser.get '/write'
      browser.get '/read'
      assert_equal 'shared', browser.last_response.body
    end

    # compare to: test_routing: allow global provides
    should "set content_type to :html if none can be determined" do
      mock_app do
        provides :xml

        get("/foo"){ "Foo in #{content_type}" }
        get("/bar"){ "Foo in #{content_type}" }
      end

      get '/foo', {}, { 'HTTP_ACCEPT' => 'application/xml' }
      assert_equal 'Foo in xml', body
      get '/foo'
      assert_equal 'Foo in xml', body

      get '/bar', {}, { 'HTTP_ACCEPT' => 'application/xml' }
      assert_equal "Foo in html", body
    end # content_type to :html

    context "errors" do
      should "haven't mapped errors on development" do
        mock_app { get('/'){ 'HI' } }
        get "/"
        assert @app.errors.empty?
      end

      should "have mapped errors on production" do
        mock_app { set :environment, :production; get('/'){ 'HI' } }
        get "/"
        assert_equal 1, @app.errors.size
      end

      should "overide errors" do
        mock_app do
          set :environment, :production
          get('/'){ raise }
          error(::Exception){ 'custom error' }
        end
        get "/"
        assert_equal 1, @app.errors.size
        assert_equal 'custom error', body
      end
    end
  end # application functionality
end
