require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Padrino::Flash do
  context 'storage' do
    before do
      @storage = Padrino::Flash::Storage.new(
        :success => 'Success msg',
        :error   => 'Error msg',
        :notice  => 'Notice msg',
        :custom  => 'Custom msg'
      )
      @storage[:one] = 'One msg'
      @storage[:two] = 'Two msg'
    end

    should 'acts like hash' do
      assert_respond_to @storage, :[]
    end

    should 'know its size' do
      assert_equal 4, @storage.length
      assert_equal @storage.length, @storage.size
    end

    should 'sweep its content' do
      assert_equal 2, @storage.sweep.size
      assert_empty @storage.sweep
    end

    should 'discard everything' do
      assert_empty @storage.discard.sweep
    end

    should 'discard specified key' do
      assert_equal 1, @storage.discard(:one).sweep.size
    end

    should 'keep everything' do
      assert_equal 2, @storage.sweep.keep.sweep.size
    end

    should 'keep only specified key' do
      assert_equal 1, @storage.sweep.keep(:one).sweep.size
    end

    should 'not know the values you set right away' do
      @storage[:foo] = 'bar'
      assert_nil @storage[:foo]
    end

    should 'knows the values you set next time' do
      @storage[:foo] = 'bar'
      @storage.sweep
      assert_equal 'bar', @storage[:foo]
    end

    should 'set values for now' do
      @storage.now[:foo] = 'bar'
      assert_equal 'bar', @storage[:foo]
    end

    should 'forgets values you set only for now next time' do
      @storage.now[:foo] = 'bar'
      @storage.sweep
      assert_nil @storage[:foo]
    end
  end

  routes = Proc.new do
    get :index do
      params[:key] ? flash[params[:key].to_sym].to_s : flash.now.inspect
    end

    post :index do
      params.each { |k,v| flash[k.to_sym] = v.to_s }
      flash.next.inspect
    end

    get :session do
      settings.sessions?.inspect
    end

    get :redirect do
      redirect url(:index, :key => :foo), 301, :foo => 'redirected!'
    end

    get :success do
      flash.success = 'Yup'
    end

    get :error do
      flash.error = 'Arg'
    end

    get :notice do
      flash.notice = 'Mmm'
    end
  end

  context 'padrino application without sessions' do
    before { mock_app(&routes) }

    should 'show nothing' do
      get '/'
      assert_equal '{}', body
    end

    should 'set a flash' do
      post '/', :foo => :bar
      assert_equal '{:foo=>"bar"}', body
    end
  end

  context 'padrino application with sessions' do
    before do
      mock_app { enable :sessions; class_eval(&routes) }
    end

    should 'be sure have sessions enabled' do
      assert @app.sessions
      get '/session'
      assert_equal 'true', body
    end

    should 'show nothing' do
      get '/'
      assert_equal '{}', body
    end

    should 'set a flash' do
      post '/', :foo => :bar
      assert_equal '{:foo=>"bar"}', body
    end

    should 'get a flash' do
      post '/', :foo => :bar
      get  '/', :key => :foo
      assert_equal 'bar', body
      post '/'
      assert_equal '{}', body
    end

    should 'follow redirects with flash' do
      get '/redirect'
      follow_redirect!
      assert_equal 'redirected!', body
      assert 301, status
    end

    should 'set success' do
      get '/success'
      get '/', :key => :success
      assert_equal 'Yup', body
    end

    should 'set error' do
      get '/error'
      get '/', :key => :error
      assert_equal 'Arg', body
    end

    should 'set notice' do
      get '/notice'
      get '/', :key => :notice
      assert_equal 'Mmm', body
    end
  end
end
