require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/markup_app/app')

describe "OutputHelpers" do
  def app
    MarkupDemo.tap { |app| app.set :environment, :test }
  end

  context 'for #content_for method' do
    should 'work for erb templates' do
      visit '/erb/content_for'
      assert_have_selector '.demo h1', :content => "This is content yielded from a content_for"
      assert_have_selector '.demo2 h1', :content => "This is content yielded with name Johnny Smith"
    end

    should "work for haml templates" do
      visit '/haml/content_for'
      assert_have_selector '.demo h1', :content => "This is content yielded from a content_for"
      assert_have_selector '.demo2 h1', :content => "This is content yielded with name Johnny Smith"
    end

    should "work for slim templates" do
      visit '/slim/content_for'
      assert_have_selector '.demo h1', :content => "This is content yielded from a content_for"
      assert_have_selector '.demo2 h1', :content => "This is content yielded with name Johnny Smith"
    end
  end # content_for

  context "for #content_for? method" do
    should 'work for erb templates' do
      visit '/erb/content_for'
      assert_have_selector '.demo_has_content', :content => "true"
      assert_have_selector '.fake_has_content', :content => "false"
    end

    should "work for haml templates" do
      visit '/haml/content_for'
      assert_have_selector '.demo_has_content', :content => "true"
      assert_have_selector '.fake_has_content', :content => "false"
    end

    should "work for slim templates" do
      visit '/slim/content_for'
      assert_have_selector '.demo_has_content', :content => "true"
      assert_have_selector '.fake_has_content', :content => "false"
    end
  end # content_for?

  context 'for #capture_html method' do
    should "work for erb templates" do
      visit '/erb/capture_concat'
      assert_have_selector 'p span', :content => "Captured Line 1"
      assert_have_selector 'p span', :content => "Captured Line 2"
    end

    should "work for haml templates" do
      visit '/haml/capture_concat'
      assert_have_selector 'p span', :content => "Captured Line 1"
      assert_have_selector 'p span', :content => "Captured Line 2"
    end

    should "work for slim templates" do
      visit '/slim/capture_concat'
      assert_have_selector 'p span', :content => "Captured Line 1"
      assert_have_selector 'p span', :content => "Captured Line 2"
    end
  end

  context 'for #concat_content method' do
    should "work for erb templates" do
      visit '/erb/capture_concat'
      assert_have_selector 'p', :content => "Concat Line 3", :count => 1
    end

    should "work for haml templates" do
      visit '/haml/capture_concat'
      assert_have_selector 'p', :content => "Concat Line 3", :count => 1
    end

    should "work for slim templates" do
      visit '/slim/capture_concat'
      assert_have_selector 'p', :content => "Concat Line 3", :count => 1
    end
  end

  context 'for #block_is_template?' do
    should "work for erb templates" do
      visit '/erb/capture_concat'
      assert_have_selector 'p', :content => "The erb block passed in is a template", :class => 'is_template'
      # TODO Get ERB template detection working (fix block_is_erb? method)
      # assert_have_no_selector 'p', :content => "The ruby block passed in is a template", :class => 'is_template'
    end

    should "work for haml templates" do
      visit '/haml/capture_concat'
      assert_have_selector 'p', :content => "The haml block passed in is a template", :class => 'is_template'
      assert_have_no_selector 'p', :content => "The ruby block passed in is a template", :class => 'is_template'
    end

    should_eventually "work for slim templates" do
      visit '/slim/capture_concat'
      assert_have_selector 'p', :content => "The slim block passed in is a template", :class => 'is_template'
      assert_have_no_selector 'p', :content => "The ruby block passed in is a template", :class => 'is_template'
    end
  end

  context 'for #current_engine method' do
    should 'detect correctly current engine for erb' do
      visit '/erb/current_engine'
      assert_have_selector 'p.start', :content => "erb"
      assert_have_selector 'p.haml',  :content => "haml"
      assert_have_selector 'p.erb',   :content => "erb"
      assert_have_selector 'p.slim',  :content => "slim"
      assert_have_selector 'p.end',   :content => "erb"
    end

    should 'detect correctly current engine for haml' do
      visit '/haml/current_engine'
      assert_have_selector 'p.start', :content => "haml"
      assert_have_selector 'p.haml',  :content => "haml"
      assert_have_selector 'p.erb',   :content => "erb"
      assert_have_selector 'p.slim',  :content => "slim"
      assert_have_selector 'p.end',   :content => "haml"
    end

    should 'detect correctly current engine for slim' do
      visit '/slim/current_engine'
      assert_have_selector 'p.start', :content => "slim"
      assert_have_selector 'p.haml',  :content => "haml"
      assert_have_selector 'p.erb',   :content => "erb"
      assert_have_selector 'p.slim',  :content => "slim"
      assert_have_selector 'p.end',   :content => "slim"
    end
  end

  context 'for #partial method in simple sinatra application' do
    should 'properly output in erb' do
      visit '/erb/simple_partial'
      assert_have_selector 'p.erb',  :content => "erb"
    end

    should 'properly output in haml' do
      visit '/haml/simple_partial'
      assert_have_selector 'p.haml',  :content => "haml"
    end

    should 'properly output in slim' do
      visit '/slim/simple_partial'
      assert_have_selector 'p.slim',  :content => "slim"
    end
  end
end
