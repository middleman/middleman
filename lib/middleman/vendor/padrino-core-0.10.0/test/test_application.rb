require File.expand_path(File.dirname(__FILE__) + '/helper')

class PadrinoTestApp < Padrino::Application; end
class PadrinoTestApp2 < Padrino::Application; end

class TestApplication < Test::Unit::TestCase
  def setup
    Padrino.clear!
  end

  def teardown
    remove_views
  end

  context 'for application functionality' do

    should 'check default options' do
      assert File.identical?(__FILE__, PadrinoTestApp.app_file)
      assert_equal :padrino_test_app, PadrinoTestApp.app_name
      assert_equal :test, PadrinoTestApp.environment
      assert_equal Padrino.root("views"), PadrinoTestApp.views
      assert PadrinoTestApp.raise_errors
      assert !PadrinoTestApp.logging
      assert !PadrinoTestApp.sessions
      assert !PadrinoTestApp.dump_errors
      assert !PadrinoTestApp.show_exceptions
      assert PadrinoTestApp.raise_errors
      assert !Padrino.configure_apps
    end

    should 'check padrino specific options' do
      assert !PadrinoTestApp.instance_variable_get(:@_configured)
      PadrinoTestApp.send(:setup_application!)
      assert_equal :padrino_test_app, PadrinoTestApp.app_name
      assert_equal 'StandardFormBuilder', PadrinoTestApp.default_builder
      assert PadrinoTestApp.instance_variable_get(:@_configured)
      assert !PadrinoTestApp.reload?
      assert !PadrinoTestApp.flash
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
  end # application functionality

end