require File.expand_path(File.dirname(__FILE__) + '/helper')
require 'i18n'

describe "Rendering" do
  def setup
    Padrino::Application.send(:register, Padrino::Rendering)
    Padrino::Rendering::DEFAULT_RENDERING_OPTIONS[:strict_format] = false
  end

  def teardown
    remove_views
  end

  context 'for application layout functionality' do

    should 'get no layout' do
      mock_app do
        get("/"){ "no layout" }
      end

      get "/"
      assert_equal "no layout", body
    end

    should 'be compatible with sinatra layout' do
      mock_app do
        layout do
          "this is a <%= yield %>"
        end

        get("/"){ render :erb, "sinatra layout" }
      end

      get "/"
      assert_equal "this is a sinatra layout", body
    end

    should 'use rails way layout' do
      with_layout :application, "this is a <%= yield %>" do
        mock_app do
          get("/"){ render :erb, "rails way layout" }
        end

        get "/"
        assert_equal "this is a rails way layout", body
      end
    end

    should 'use rails way for a custom layout' do
      with_layout "layouts/custom", "this is a <%= yield %>" do
        mock_app do
          layout :custom
          get("/"){ render :erb, "rails way custom layout" }
        end

        get "/"
        assert_equal "this is a rails way custom layout", body
      end
    end

    should 'not use layout' do
      with_layout :application, "this is a <%= yield %>" do
        with_view :index, "index" do
          mock_app do
            get("/with/layout"){ render :index }
            get("/without/layout"){ render :index, :layout => false }
          end
          get "/with/layout"
          assert_equal "this is a index", body
          get "/without/layout"
          assert_equal "index", body
        end
      end
    end

    should 'not use layout with js format' do
      create_layout :application, "this is an <%= yield %>"
      create_view :foo, "erb file"
      create_view :foo, "js file", :format => :js
      mock_app do
        get('/layout_test', :provides => [:html, :js]){ render :foo }
      end
      get "/layout_test"
      assert_equal "this is an erb file", body
      get "/layout_test.js"
      assert_equal "js file", body
    end

    should 'use correct layout for each format' do
      create_layout :application, "this is an <%= yield %>"
      create_layout :application, "document start <%= yield %> end", :format => :xml
      create_view :foo, "erb file"
      create_view :foo, "xml file", :format => :xml
      mock_app do
        get('/layout_test', :provides => [:html, :xml]){ render :foo }
      end
      get "/layout_test"
      assert_equal "this is an erb file", body
      get "/layout_test.xml"
      assert_equal "document start xml file end", body
    end

    should 'by default use html file when no other is given' do
      create_layout :baz, "html file", :format => :html

      mock_app do
        get('/content_type_test', :provides => [:html, :xml]) { render :baz }
      end

      get "/content_type_test"
      assert_equal "html file", body
      get "/content_type_test.html"
      assert_equal "html file", body
      get "/content_type_test.xml"
      assert_equal "html file", body
    end

    should 'not use html file when DEFAULT_RENDERING_OPTIONS[:strict_format] == true' do
      create_layout :foo, "html file", :format => :html

      mock_app do
        get('/default_rendering_test', :provides => [:html, :xml]) { render :foo }
      end

      @save = Padrino::Rendering::DEFAULT_RENDERING_OPTIONS
      Padrino::Rendering::DEFAULT_RENDERING_OPTIONS[:strict_format] = true

      get "/default_rendering_test"
      assert_equal "html file", body
      assert_raises Padrino::Rendering::TemplateNotFound do
        get "/default_rendering_test.xml"
      end

      Padrino::Rendering::DEFAULT_RENDERING_OPTIONS.merge!(@save)
    end

    should 'use correct layout with each controller' do
      create_layout :foo, "foo layout at <%= yield %>"
      create_layout :bar, "bar layout at <%= yield %>"
      create_layout :application, "default layout at <%= yield %>"
      mock_app do
        get("/"){ render :erb, "application" }
        controller :foo do
          layout :foo
          get("/"){ render :erb, "foo" }
        end
        controller :bar do
          layout :bar
          get("/"){ render :erb, "bar" }
        end
        controller :none do
          get("/") { render :erb, "none" }
          get("/with_foo_layout")  { render :erb, "none with layout", :layout => :foo }
        end
      end
      get "/foo"
      assert_equal "foo layout at foo", body
      get "/bar"
      assert_equal "bar layout at bar", body
      get "/none"
      assert_equal "default layout at none", body
      get "/none/with_foo_layout"
      assert_equal "foo layout at none with layout", body
      get "/"
      assert_equal "default layout at application", body
    end
  end

  should 'solve layout in layouts paths' do
    create_layout :foo, "foo layout <%= yield %>"
    create_layout :"layouts/bar", "bar layout <%= yield %>"
    mock_app do
      get("/") { render :erb, "none" }
      get("/foo") { render :erb, "foo", :layout => :foo }
      get("/bar") { render :erb, "bar", :layout => :bar }
    end
    get "/"
    assert_equal "none", body
    get "/foo"
    assert_equal "foo layout foo", body
    get "/bar"
    assert_equal "bar layout bar", body
  end

  should 'render correctly if layout was not found or not exist' do
    create_layout :application, "application layout for <%= yield %>"
    create_view :foo, "index", :format => :html
    create_view :foo, "xml.rss", :format => :rss
    mock_app do
      get("/foo", :provides => [:html, :rss]) { render('foo') }
      get("/baz", :provides => :js) { render(:erb, 'baz') }
      get("/bar") { render :haml, "haml" }
    end
    get "/foo"
    assert_equal "application layout for index", body
    get "/foo.rss"
    assert_equal "<rss/>", body.chomp
    get "/baz.js"
    assert_equal "baz", body
    get "/bar"
    assert_equal "haml", body.chomp
  end

  context 'for application render functionality' do

    should "work properly with logging and missing layout" do
      create_view :index, "<%= foo %>"
      mock_app do
        enable :logging
        get("/") { render "index", { :layout => true }, { :foo => "bar" } }
      end
      get "/"
      assert_equal "bar", body
    end

    should "work properly with logging and layout" do
      create_layout :application, "layout <%= yield %>"
      create_view :index, "<%= foo %>"
      mock_app do
        enable :logging
        get("/") { render "index", { :layout => true }, { :foo => "bar" } }
      end
      get "/"
      assert_equal "layout bar", body
    end

    should 'be compatible with sinatra render' do
      mock_app do
        get("/"){ render :erb, "<%= 1+2 %>" }
      end
      get "/"
      assert_equal "3", body
    end

    should "support passing locals into render" do
      create_layout :application, "layout <%= yield %>"
      create_view :index, "<%= foo %>"
      mock_app do
        get("/") { render "index", { :layout => true }, { :foo => "bar" } }
      end
      get "/"
      assert_equal "layout bar", body
    end

    should "support passing locals into sinatra render" do
      create_layout :application, "layout <%= yield %>"
      create_view :index, "<%= foo %>"
      mock_app do
        get("/") { render :erb, :index, { :layout => true }, { :foo => "bar" } }
      end
      get "/"
      assert_equal "layout bar", body
    end

    should "support passing locals into special nil engine render" do
      create_layout :application, "layout <%= yield %>"
      create_view :index, "<%= foo %>"
      mock_app do
        get("/") { render nil, :index, { :layout => true }, { :foo => "bar" } }
      end
      get "/"
      assert_equal "layout bar", body
    end

    should 'be compatible with sinatra views' do
      with_view :index, "<%= 1+2 %>" do
        mock_app do
          get("/foo") { render :erb, :index }
          get("/bar") { erb :index }
          get("/dir") { "3" }
          get("/inj") { erb "<%= 2+1 %>" }
          get("/rnj") { render :erb, "<%= 2+1 %>" }
        end
        get "/foo"
        assert_equal "3", body
        get "/bar"
        assert_equal "3", body
        get "/dir"
        assert_equal "3", body
        get "/inj"
        assert_equal "3", body
        get "/rnj"
        assert_equal "3", body
      end
    end

    should 'resolve template engine' do
      with_view :index, "<%= 1+2 %>" do
        mock_app do
          get("/foo") { render :index }
          get("/bar") { render "/index" }
        end
        get "/foo"
        assert_equal "3", body
        get "/bar"
        assert_equal "3", body
      end
    end

    should 'resolve template content type' do
      create_view :foo, "Im Js", :format => :js
      create_view :foo, "Im Erb"
      mock_app do
        get("/foo", :provides => :js) { render :foo }
        get("/bar.js") { render :foo }
      end
      get "/foo.js"
      assert_equal "Im Js", body
      # TODO: implement this!
      # get "/bar.js"
      # assert_equal "Im Js", body
    end

    should 'resolve with explicit template format' do
      create_view :foo, "Im Js", :format => :js
      create_view :foo, "Im Haml", :format => :haml
      create_view :foo, "Im Xml", :format => :xml
      mock_app do
        get("/foo_normal", :provides => :js) { render 'foo' }
        get("/foo_haml", :provides => :js) { render 'foo.haml' }
        get("/foo_xml", :provides => :js) { render 'foo.xml' }
      end
      get "/foo_normal.js"
      assert_equal "Im Js", body
      get "/foo_haml.js"
      assert_equal "Im Haml\n", body
      get "/foo_xml.js"
      assert_equal "Im Xml", body
    end

    should 'resolve without explict template format' do
      create_view :foo, "Im Html"
      create_view :foo, "xml.rss", :format => :rss
      mock_app do
        get(:index, :map => "/", :provides => [:html, :rss]){ render 'foo' }
      end
      get "/", {}, { 'HTTP_ACCEPT' => 'text/html;q=0.9' }
      assert_equal "Im Html", body
      get ".rss"
      assert_equal "<rss/>\n", body
    end

    should "ignore files ending in tilde and not render them" do
      create_view :foo, "Im Wrong", :format => 'haml~'
      create_view :foo, "Im Haml",  :format => :haml
      create_view :bar, "Im Haml backup", :format => 'haml~'
      mock_app do
        get('/foo') { render 'foo' }
        get('/bar') { render 'bar' }
      end
      get '/foo'
      assert_equal "Im Haml\n", body
      assert_raises(Padrino::Rendering::TemplateNotFound) { get '/bar' }
    end

    should 'resolve template locale' do
      create_view :foo, "Im English", :locale => :en
      create_view :foo, "Im Italian", :locale => :it
      mock_app do
        get("/foo") { render :foo }
      end
      I18n.locale = :en
      get "/foo"
      assert_equal "Im English", body
      I18n.locale = :it
      get "/foo"
      assert_equal "Im Italian", body
    end

    should 'resolve template content_type and locale' do
      create_view :foo, "Im Js",          :format => :js
      create_view :foo, "Im Erb"
      create_view :foo, "Im English Erb", :locale => :en
      create_view :foo, "Im Italian Erb", :locale => :it
      create_view :foo, "Im English Js",  :format => :js, :locale => :en
      create_view :foo, "Im Italian Js",  :format => :js, :locale => :it
      mock_app do
        get("/foo", :provides => [:html, :js]) { render :foo }
      end
      I18n.locale = :none
      get "/foo.js"
      assert_equal "Im Js", body
      get "/foo"
      assert_equal "Im Erb", body
      I18n.locale = :en
      get "/foo"
      assert_equal "Im English Erb", body
      I18n.locale = :it
      get "/foo"
      assert_equal "Im Italian Erb", body
      I18n.locale = :en
      get "/foo.js"
      assert_equal "Im English Js", body
      I18n.locale = :it
      get "/foo.js"
      assert_equal "Im Italian Js", body
      I18n.locale = :en
      get "/foo.pk"
      assert_equal 405, status
    end

    should 'resolve template content_type and locale with layout' do
      create_layout :foo, "Hello <%= yield %> in a Js layout",     :format => :js
      create_layout :foo, "Hello <%= yield %> in a Js-En layout",  :format => :js, :locale => :en
      create_layout :foo, "Hello <%= yield %> in a Js-It layout",  :format => :js, :locale => :it
      create_layout :foo, "Hello <%= yield %> in a Erb-En layout", :locale => :en
      create_layout :foo, "Hello <%= yield %> in a Erb-It layout", :locale => :it
      create_layout :foo, "Hello <%= yield %> in a Erb layout"
      create_view   :bar, "Im Js",          :format => :js
      create_view   :bar, "Im Erb"
      create_view   :bar, "Im English Erb", :locale => :en
      create_view   :bar, "Im Italian Erb", :locale => :it
      create_view   :bar, "Im English Js",  :format => :js, :locale => :en
      create_view   :bar, "Im Italian Js",  :format => :js, :locale => :it
      create_view   :bar, "Im a json",      :format => :json
      mock_app do
        layout :foo
        get("/bar", :provides => [:html, :js, :json]) { render :bar }
      end
      I18n.locale = :none
      get "/bar.js"
      assert_equal "Hello Im Js in a Js layout", body
      get "/bar"
      assert_equal "Hello Im Erb in a Erb layout", body
      I18n.locale = :en
      get "/bar"
      assert_equal "Hello Im English Erb in a Erb-En layout", body
      I18n.locale = :it
      get "/bar"
      assert_equal "Hello Im Italian Erb in a Erb-It layout", body
      I18n.locale = :en
      get "/bar.js"
      assert_equal "Hello Im English Js in a Js-En layout", body
      I18n.locale = :it
      get "/bar.js"
      assert_equal "Hello Im Italian Js in a Js-It layout", body
      I18n.locale = :en
      get "/bar.json"
      assert_equal "Im a json", body
      get "/bar.pk"
      assert_equal 405, status
    end

    should 'renders erb with blocks' do
      mock_app do
        def container
          @_out_buf << "THIS."
          yield
          @_out_buf << "SPARTA!"
        end
        def is; "IS."; end
        get '/' do
          render :erb, '<% container do %> <%= is %> <% end %>'
        end
      end
      get '/'
      assert ok?
      assert_equal 'THIS. IS. SPARTA!', body
    end
  end
end
