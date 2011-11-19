require File.expand_path(File.dirname(__FILE__) + '/helper')

describe "Mounter" do
  class ::TestApp < Padrino::Application; end

  def setup
    $VERBOSE, @_verbose_was = nil, $VERBOSE
    Padrino.clear!
  end

  def teardown
    $VERBOSE = @_verbose_was
  end

  context 'for mounter functionality' do
    should 'check methods' do
      mounter = Padrino::Mounter.new("test_app", :app_file => "/path/to/test.rb")
      mounter.to("/test_app")
      assert_kind_of Padrino::Mounter, mounter
      assert_respond_to Padrino::Mounter, :new
      assert_respond_to mounter, :to
      assert_respond_to mounter, :map_onto
      assert_equal "test_app", mounter.name
      assert_equal "TestApp", mounter.app_class
      assert_equal "/path/to/test.rb", mounter.app_file
      assert_equal "/test_app", mounter.uri_root
      assert_equal File.dirname(mounter.app_file), mounter.app_root
    end

    should 'check locate_app_file with __FILE__' do
      mounter = Padrino::Mounter.new("test_app", :app_file => __FILE__)
      mounter.to("/test_app")
      assert_equal "test_app", mounter.name
      assert_equal "TestApp", mounter.app_class
      assert_equal __FILE__, mounter.app_file
      assert_equal "/test_app", mounter.uri_root
      assert_equal File.dirname(mounter.app_file), mounter.app_root
    end

    should 'mount an app' do
      class ::AnApp < Padrino::Application; end
      Padrino.mount("an_app").to("/")
      assert_equal AnApp, Padrino.mounted_apps.first.app_obj
      assert_equal ["an_app"], Padrino.mounted_apps.map(&:name)
    end

    should 'correctly mount an app in a namespace' do
      module ::SomeNamespace
        class AnApp < Padrino::Application; end
      end
      Padrino.mount("some_namespace/an_app").to("/")
      assert_equal SomeNamespace::AnApp, Padrino.mounted_apps.first.app_obj
      assert_equal ["some_namespace/an_app"], Padrino.mounted_apps.map(&:name)
    end

    should 'mount a primary app to root uri' do
      mounter = Padrino.mount("test_app", :app_file => __FILE__).to("/")
      assert_equal "test_app", mounter.name
      assert_equal "TestApp", mounter.app_class
      assert_equal TestApp, mounter.app_obj
      assert_equal __FILE__, mounter.app_file
      assert_equal "/", mounter.uri_root
      assert_equal File.dirname(mounter.app_file), mounter.app_root
    end

    should 'mount a primary app to sub_uri' do
      mounter = Padrino.mount("test_app", :app_file => __FILE__).to('/me')
      assert_equal "test_app", mounter.name
      assert_equal "TestApp", mounter.app_class
      assert_equal TestApp, mounter.app_obj
      assert_equal __FILE__, mounter.app_file
      assert_equal "/me", mounter.uri_root
      assert_equal File.dirname(mounter.app_file), mounter.app_root
    end

    should "raise error when app has no located file" do
      # TODO enabling this screws minitest
      # assert_raises(Padrino::Mounter::MounterException) { Padrino.mount("tester_app").to('/test') }
      assert_equal 0, Padrino.mounted_apps.size
    end

    should "raise error when app has no located object" do
      assert_raises(Padrino::Mounter::MounterException) { Padrino.mount("tester_app", :app_file => "/path/to/file.rb").to('/test') }
      assert_equal 0, Padrino.mounted_apps.size
    end

    should 'mount multiple apps' do
      class ::OneApp < Padrino::Application; end
      class ::TwoApp < Padrino::Application; end

      Padrino.mount("one_app").to("/one_app")
      Padrino.mount("two_app").to("/two_app")
      # And testing no duplicates
      Padrino.mount("one_app").to("/one_app")
      Padrino.mount("two_app").to("/two_app")

      assert_equal OneApp, Padrino.mounted_apps[0].app_obj
      assert_equal TwoApp, Padrino.mounted_apps[1].app_obj
      assert_equal 2, Padrino.mounted_apps.size, "should not mount duplicate apps"
      assert_equal ["one_app", "two_app"], Padrino.mounted_apps.map(&:name)
    end

    should 'change mounted_root' do
      Padrino.mounted_root = "fixtures"
      assert_equal Padrino.root("fixtures", "test", "app.rb"), Padrino.mounted_root("test", "app.rb")
      Padrino.mounted_root = "apps"
      assert_equal Padrino.root("apps", "test", "app.rb"), Padrino.mounted_root("test", "app.rb")
      Padrino.mounted_root = nil
      assert_equal Padrino.root("test", "app.rb"), Padrino.mounted_root("test", "app.rb")
    end

    should "be able to access routes data for mounted apps" do
      class ::OneApp < Padrino::Application
        get("/test") { "test" }
        get(:index, :provides => [:js, :json]) { "index" }
        controllers :posts do
          get(:index) { "index" }
          get(:new, :provides => :js) { "new" }
          get(:show, :provides => [:js, :html], :with => :id) { "show" }
          post(:create, :provides => :js, :with => :id) { "create" }
        end
      end
      class ::TwoApp < Padrino::Application
        controllers :users do
          get(:index) { "users" }
          get(:new) { "users new" }
          post(:create) { "users create" }
          put(:update) { "users update" }
          delete(:destroy) { "users delete" }
        end
      end

      Padrino.mount("one_app").to("/")
      Padrino.mount("two_app").to("/two_app")

      assert_equal 11, Padrino.mounted_apps[0].routes.size
      assert_equal 7, Padrino.mounted_apps[1].routes.size
      assert_equal 5, Padrino.mounted_apps[0].named_routes.size
      assert_equal 5, Padrino.mounted_apps[1].named_routes.size

      first_route = Padrino.mounted_apps[0].named_routes[3]
      assert_equal "posts_show", first_route.identifier.to_s
      assert_equal "(:posts, :show)", first_route.name
      assert_equal "GET", first_route.verb
      assert_equal "/posts/show/:id(.:format)", first_route.path
      another_route = Padrino.mounted_apps[1].named_routes[2]
      assert_equal "users_create", another_route.identifier.to_s
      assert_equal "(:users, :create)", another_route.name
      assert_equal "POST", another_route.verb
      assert_equal "/two_app/users/create", another_route.path
    end

    should 'correctly instantiate a new padrino application' do
      mock_app do
        get("/demo_1"){ "Im Demo 1" }
        get("/demo_2"){ "Im Demo 2" }
      end

      get '/demo_1'
      assert_equal "Im Demo 1", response.body
      get '/demo_2'
      assert_equal "Im Demo 2", response.body
    end

    should "not clobber the public setting when mounting an app" do
      class ::PublicApp < Padrino::Application
        set :root, "/root"
        set :public_folder, File.expand_path(File.dirname(__FILE__))
      end

      Padrino.mount("public_app").to("/public")
      res = Rack::MockRequest.new(Padrino.application).get("/public/test_mounter.rb")
      assert res.ok?
      assert_equal File.read(__FILE__), res.body
    end
  end
end
