require File.expand_path(File.dirname(__FILE__) + '/helper')

describe "Application" do
  before { Padrino.clear! }
  after  { remove_views }

  context 'CSRF protection' do
    context "with CSRF protection on" do
      before do
        mock_app do
          enable :sessions
          enable :protect_from_csrf
          post('/'){ 'HI' }
        end
      end

      should "not allow requests without tokens" do
        post "/"
        assert_equal 403, status
      end

      should "allow requests with correct tokens" do
        post "/", {"authenticity_token" => "a"}, 'rack.session' => {:csrf => "a"}
        assert_equal 200, status
      end

      should "not allow requests with incorrect tokens" do
        post "/", {"authenticity_token" => "a"}, 'rack.session' => {:csrf => "b"}
        assert_equal 403, status
      end
    end

    context "without CSRF protection on" do
      before do
        mock_app do
          enable :sessions
          disable :protect_from_csrf
          post('/'){ 'HI' }
        end
      end

      should "allows requests without tokens" do
        post "/"
        assert_equal 200, status
      end

      should "allow requests with correct tokens" do
        post "/", {"authenticity_token" => "a"}, 'rack.session' => {:csrf => "a"}
        assert_equal 200, status        
      end

      should "allow requests with incorrect tokens" do
        post "/", {"authenticity_token" => "a"}, 'rack.session' => {:csrf => "b"}
        assert_equal 200, status
      end
    end

    context "with optional CSRF protection" do
      before do
        mock_app do
          enable :sessions
          enable :protect_from_csrf
          set :allow_disabled_csrf, true
          post('/on') { 'HI' }
          post('/off', :csrf_protection => false) { 'HI' }
        end
      end

      should "allow access to routes with csrf_protection off" do
        post "/off"
        assert_equal 200, status
      end

      should "not allow access to routes with csrf_protection on" do
        post "/on"
        assert_equal 403, status
      end
    end
  end
end