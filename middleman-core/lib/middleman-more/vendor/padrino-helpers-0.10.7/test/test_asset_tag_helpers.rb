require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/markup_app/app')

describe "AssetTagHelpers" do
  include Padrino::Helpers::AssetTagHelpers

  def app
    MarkupDemo.tap { |app| app.set :environment, :test }
  end

  def flash
    @_flash ||= { :notice => "Demo notice" }
  end

  context 'for #flash_tag method' do
    should "display flash with no given attributes" do
      assert_has_tag('div.notice', :content => "Demo notice") { flash_tag(:notice) }
    end
    should "display flash with given attributes" do
      actual_html = flash_tag(:notice, :class => 'notice', :id => 'notice-area')
      assert_has_tag('div.notice#notice-area', :content => "Demo notice") { actual_html }
    end
    should "display multiple flash tags with given attributes" do
      flash[:error] = 'wrong'
      flash[:success] = 'okey'
      actual_html = flash_tag(:success, :error, :id => 'area')
      assert_has_tag('div.success#area', :content => flash[:success]) { actual_html }
      assert_has_tag('div.error#area', :content => flash[:error]) { actual_html }
      assert_has_no_tag('div.notice') { actual_html }
    end
  end

  context 'for #link_to method' do
    should "display link element with no given attributes" do
      assert_has_tag('a', :content => "Sign up", :href => '/register') { link_to('Sign up', '/register') }
    end

    should "display link element with given attributes" do
      actual_html = link_to('Sign up', '/register', :class => 'first', :id => 'linky')
      assert_has_tag('a#linky.first', :content => "Sign up", :href => '/register') { actual_html }
    end

    should "display link element with anchor attribute" do
      actual_html = link_to("Anchor", "/anchor", :anchor => :foo)
      assert_has_tag('a', :content => "Anchor", :href => '/anchor#foo') { actual_html }
    end

    should "display link element with void url and options" do
      actual_link = link_to('Sign up', :class => "test")
      assert_has_tag('a', :content => "Sign up", :href => '#', :class => 'test') { actual_link }
    end

    should "display link element with remote option" do
      actual_link = link_to('Sign up', '/register', :remote => true)
      assert_has_tag('a', :content => "Sign up", :href => '/register', 'data-remote' => 'true') { actual_link }
    end

    should "display link element with method option" do
      actual_link = link_to('Sign up', '/register', :method => :delete)
      assert_has_tag('a', :content => "Sign up", :href => '/register', 'data-method' => 'delete', :rel => 'nofollow') { actual_link }
    end

    should "display link element with confirm option" do
      actual_link = link_to('Sign up', '/register', :confirm => "Are you sure?")
      assert_has_tag('a', :content => "Sign up", :href => '/register', 'data-confirm' => 'Are you sure?') { actual_link }
    end

    should "display link element with ruby block" do
      actual_link = link_to('/register', :class => 'first', :id => 'binky') { "Sign up" }
      assert_has_tag('a#binky.first', :content => "Sign up", :href => '/register') { actual_link }
    end

    should "display link block element in haml" do
      visit '/haml/link_to'
      assert_have_selector :a, :content => "Test 1 No Block", :href => '/test1', :class => 'test', :id => 'test1'
      assert_have_selector :a, :content => "Test 2 With Block", :href => '/test2', :class => 'test', :id => 'test2'
    end

    should "display link block element in erb" do
      visit '/erb/link_to'
      assert_have_selector :a, :content => "Test 1 No Block", :href => '/test1', :class => 'test', :id => 'test1'
      assert_have_selector :a, :content => "Test 2 With Block", :href => '/test2', :class => 'test', :id => 'test2'
    end

    should "display link block element in slim" do
      visit '/slim/link_to'
      assert_have_selector :a, :content => "Test 1 No Block", :href => '/test1', :class => 'test', :id => 'test1'
      assert_have_selector :a, :content => "Test 2 With Block", :href => '/test2', :class => 'test', :id => 'test2'
    end
  end

  context 'for #mail_to method' do
    should "display link element for mail to no caption" do
      actual_html = mail_to('test@demo.com')
      assert_has_tag(:a, :href => "mailto:test@demo.com", :content => 'test@demo.com') { actual_html }
    end

    should "display link element for mail to with caption" do
      actual_html = mail_to('test@demo.com', "My Email", :class => 'demo')
      assert_has_tag(:a, :href => "mailto:test@demo.com", :content => 'My Email', :class => 'demo') { actual_html }
    end

    should "display link element for mail to with caption and mail options" do
      actual_html = mail_to('test@demo.com', "My Email", :subject => 'demo test', :class => 'demo', :cc => 'foo@test.com')
      assert_has_tag(:a, :class => 'demo') { actual_html }
      assert_match %r{mailto\:test\@demo.com\?}, actual_html
      assert_match %r{cc=foo\@test\.com}, actual_html
      assert_match %r{subject\=demo\%20test}, actual_html
    end

    should "display mail link element in haml" do
      visit '/haml/mail_to'
      assert_have_selector 'p.simple a', :href => 'mailto:test@demo.com', :content => 'test@demo.com'
      assert_have_selector 'p.captioned a', :href => 'mailto:test@demo.com', :content => 'Click my Email'
    end

    should "display mail link element in erb" do
      visit '/erb/mail_to'
      assert_have_selector 'p.simple a', :href => 'mailto:test@demo.com', :content => 'test@demo.com'
      assert_have_selector 'p.captioned a', :href => 'mailto:test@demo.com', :content => 'Click my Email'
    end

    should "display mail link element in slim" do
      visit '/slim/mail_to'
      assert_have_selector 'p.simple a', :href => 'mailto:test@demo.com', :content => 'test@demo.com'
      assert_have_selector 'p.captioned a', :href => 'mailto:test@demo.com', :content => 'Click my Email'
    end
  end

  context 'for #meta_tag method' do
    should "display meta tag with given content and name" do
      actual_html = meta_tag("weblog,news", :name => "keywords")
      assert_has_tag("meta", :name => "keywords", "content" => "weblog,news") { actual_html }
    end

    should "display meta tag with given content and http-equiv" do
      actual_html = meta_tag("text/html; charset=UTF-8", :"http-equiv" => "Content-Type")
      assert_has_tag("meta", :"http-equiv" => "Content-Type", "content" => "text/html; charset=UTF-8") { actual_html }
    end

    should "display meta tag element in haml" do
      visit '/haml/meta_tag'
      assert_have_selector 'meta', "content" => "weblog,news", :name => "keywords"
      assert_have_selector 'meta', "content" => "text/html; charset=UTF-8", :"http-equiv" => "Content-Type"
    end

    should "display meta tag element in erb" do
      visit '/erb/meta_tag'
      assert_have_selector 'meta', "content" => "weblog,news", :name => "keywords"
      assert_have_selector 'meta', "content" => "text/html; charset=UTF-8", :"http-equiv" => "Content-Type"
    end

    should "display meta tag element in slim" do
      visit '/slim/meta_tag'
      assert_have_selector 'meta', "content" => "weblog,news", :name => "keywords"
      assert_have_selector 'meta', "content" => "text/html; charset=UTF-8", :"http-equiv" => "Content-Type"
    end
  end

  context 'for #image_tag method' do
    should "display image tag absolute link with no options" do
      time = stop_time_for_test
      assert_has_tag('img', :src => "/absolute/pic.gif") { image_tag('/absolute/pic.gif') }
    end

    should "display image tag relative link with specified uri root" do
      time = stop_time_for_test
      self.class.stubs(:uri_root).returns("/blog")
      assert_has_tag('img', :src => "/blog/images/relative/pic.gif?#{time.to_i}") { image_tag('relative/pic.gif') }
    end

    should "display image tag relative link with options" do
      time = stop_time_for_test
      assert_has_tag('img.photo', :src => "/images/relative/pic.gif?#{time.to_i}") {
        image_tag('relative/pic.gif', :class => 'photo') }
    end

    should "display image tag uri link with options" do
      time = stop_time_for_test
      assert_has_tag('img.photo', :src => "http://demo.org/pic.gif") { image_tag('http://demo.org/pic.gif', :class => 'photo') }
    end

    should "display image tag relative link with incorrect spacing" do
      time = stop_time_for_test
      assert_has_tag('img.photo', :src => "/images/%20relative/%20pic.gif%20%20?#{time.to_i}") {
        image_tag(' relative/ pic.gif  ', :class => 'photo') }
    end

    should "not use a timestamp if stamp setting is false" do
      self.class.expects(:asset_stamp).returns(false)
      assert_has_tag('img', :src => "/absolute/pic.gif") { image_tag('/absolute/pic.gif') }
    end

    should "have xhtml convention tag" do
      self.class.expects(:asset_stamp).returns(false)
      assert_equal image_tag('/absolute/pic.gif'), '<img src="/absolute/pic.gif" />'
    end
  end

  context 'for #stylesheet_link_tag method' do
    should "display stylesheet link item" do
      time = stop_time_for_test
      expected_options = { :media => "screen", :rel => "stylesheet", :type => "text/css" }
      assert_has_tag('link', expected_options.merge(:href => "/stylesheets/style.css?#{time.to_i}")) { stylesheet_link_tag('style') }
    end

    should "display stylesheet link item for long relative path" do
      time = stop_time_for_test
      expected_options = { :media => "screen", :rel => "stylesheet", :type => "text/css" }
      actual_html = stylesheet_link_tag('example/demo/style')
      assert_has_tag('link', expected_options.merge(:href => "/stylesheets/example/demo/style.css?#{time.to_i}")) { actual_html }
    end

    should "display stylesheet link item with absolute path" do
      time = stop_time_for_test
      expected_options = { :media => "screen", :rel => "stylesheet", :type => "text/css" }
      actual_html = stylesheet_link_tag('/css/style')
      assert_has_tag('link', expected_options.merge(:href => "/css/style.css")) { actual_html }
    end

    should "display stylesheet link item with uri root" do
      self.class.stubs(:uri_root).returns("/blog")
      time = stop_time_for_test
      expected_options = { :media => "screen", :rel => "stylesheet", :type => "text/css" }
      actual_html = stylesheet_link_tag('style')
      assert_has_tag('link', expected_options.merge(:href => "/blog/stylesheets/style.css?#{time.to_i}")) { actual_html }
    end

    should "display stylesheet link items" do
      time = stop_time_for_test
      actual_html = stylesheet_link_tag('style', 'layout.css', 'http://google.com/style.css')
      assert_has_tag('link', :media => "screen", :rel => "stylesheet", :type => "text/css", :count => 3) { actual_html }
      assert_has_tag('link', :href => "/stylesheets/style.css?#{time.to_i}") { actual_html }
      assert_has_tag('link', :href => "/stylesheets/layout.css?#{time.to_i}") { actual_html }
      assert_has_tag('link', :href => "http://google.com/style.css") { actual_html }
      assert_equal actual_html, stylesheet_link_tag(['style', 'layout.css', 'http://google.com/style.css'])
    end

    should "not use a timestamp if stamp setting is false" do
      self.class.expects(:asset_stamp).returns(false)
      expected_options = { :media => "screen", :rel => "stylesheet", :type => "text/css" }
      assert_has_tag('link', expected_options.merge(:href => "/stylesheets/style.css")) { stylesheet_link_tag('style') }
    end
  end

  context 'for #javascript_include_tag method' do
    should "display javascript item" do
      time = stop_time_for_test
      actual_html = javascript_include_tag('application')
      assert_has_tag('script', :src => "/javascripts/application.js?#{time.to_i}", :type => "text/javascript") { actual_html }
    end

    should "display javascript item for long relative path" do
      time = stop_time_for_test
      actual_html = javascript_include_tag('example/demo/application')
      assert_has_tag('script', :src => "/javascripts/example/demo/application.js?#{time.to_i}", :type => "text/javascript") { actual_html }
    end

    should "display javascript item for path containing js" do
      time = stop_time_for_test
      actual_html = javascript_include_tag 'test/jquery.json'
      assert_has_tag('script', :src => "/javascripts/test/jquery.json?#{time.to_i}", :type => "text/javascript") { actual_html }
    end

    should "display javascript item for path containing period" do
      time = stop_time_for_test
      actual_html = javascript_include_tag 'test/jquery.min'
      assert_has_tag('script', :src => "/javascripts/test/jquery.min.js?#{time.to_i}", :type => "text/javascript") { actual_html }
    end

    should "display javascript item with absolute path" do
      time = stop_time_for_test
      actual_html = javascript_include_tag('/js/application')
      assert_has_tag('script', :src => "/js/application.js", :type => "text/javascript") { actual_html }
    end

    should "display javascript item with uri root" do
      self.class.stubs(:uri_root).returns("/blog")
      time = stop_time_for_test
      actual_html = javascript_include_tag('application')
      assert_has_tag('script', :src => "/blog/javascripts/application.js?#{time.to_i}", :type => "text/javascript") { actual_html }
    end

    should "display javascript items" do
      time = stop_time_for_test
      actual_html = javascript_include_tag('application', 'base.js', 'http://google.com/lib.js')
      assert_has_tag('script', :type => "text/javascript", :count => 3) { actual_html }
      assert_has_tag('script', :src => "/javascripts/application.js?#{time.to_i}") { actual_html }
      assert_has_tag('script', :src => "/javascripts/base.js?#{time.to_i}") { actual_html }
      assert_has_tag('script', :src => "http://google.com/lib.js") { actual_html }
      assert_equal actual_html, javascript_include_tag(['application', 'base.js', 'http://google.com/lib.js'])
    end

    should "not use a timestamp if stamp setting is false" do
      self.class.expects(:asset_stamp).returns(false)
      actual_html = javascript_include_tag('application')
      assert_has_tag('script', :src => "/javascripts/application.js", :type => "text/javascript") { actual_html }
    end
  end

  context "for #favicon_tag method" do
    should "display favicon" do
      time = stop_time_for_test
      actual_html = favicon_tag('icons/favicon.png')
      assert_has_tag('link', :rel => 'icon', :type => 'image/png', :href => "/images/icons/favicon.png?#{time.to_i}") { actual_html }
    end

    should "match type with file ext" do
      time = stop_time_for_test
      actual_html = favicon_tag('favicon.ico')
      assert_has_tag('link', :rel => 'icon', :type => 'image/ico', :href => "/images/favicon.ico?#{time.to_i}") { actual_html }
    end

    should "allow option overrides" do
      time = stop_time_for_test
      actual_html = favicon_tag('favicon.png', :type => 'image/ico')
      assert_has_tag('link', :rel => 'icon', :type => 'image/ico', :href => "/images/favicon.png?#{time.to_i}") { actual_html }
    end
  end

  context 'for #feed_tag method' do
    should "generate correctly link tag for rss" do
      assert_has_tag('link', :type => 'application/rss+xml', :rel => 'alternate', :href => "/blog/post.rss", :title => 'rss') { feed_tag :rss, "/blog/post.rss" }
    end

    should "generate correctly link tag for atom" do
      assert_has_tag('link', :type => 'application/atom+xml', :rel => 'alternate', :href => "/blog/post.atom", :title => 'atom') { feed_tag :atom, "/blog/post.atom" }
    end

    should "override options" do
      assert_has_tag('link', :type => 'my-type', :rel => 'my-rel', :href => "/blog/post.rss", :title => 'my-title') { feed_tag :rss, "/blog/post.rss", :type => "my-type", :rel => "my-rel", :title => "my-title" }
    end
  end
end
