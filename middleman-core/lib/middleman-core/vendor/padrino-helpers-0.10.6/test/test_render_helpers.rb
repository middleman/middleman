require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/render_app/app')

describe "RenderHelpers" do
  def app
    RenderDemo.tap { |app| app.set :environment, :test }
  end

  context 'for #partial method and object' do
    setup { visit '/partial/object' }
    should "render partial html with object" do
      assert_have_selector "h1", :content => "User name is John"
    end
    should "have no counter index for single item" do
      assert_have_no_selector "p", :content => "My counter is 1", :count => 1
    end
    should "include extra locals information" do
      assert_have_selector 'p', :content => "Extra is bar"
    end
  end

  context 'for #partial method and collection' do
    setup { visit '/partial/collection' }
    should "render partial html with collection" do
      assert_have_selector "h1", :content => "User name is John"
      assert_have_selector "h1", :content => "User name is Billy"
    end
    should "include counter which contains item index" do
      assert_have_selector "p", :content => "My counter is 1"
      assert_have_selector "p", :content => "My counter is 2"
    end
    should "include extra locals information" do
      assert_have_selector 'p', :content => "Extra is bar"
    end
  end

  context 'for #partial method and locals' do
    setup { visit '/partial/locals' }
    should "render partial html with locals" do
      assert_have_selector "h1", :content => "User name is John"
    end
    should "have no counter index for single item" do
      assert_have_no_selector "p", :content => "My counter is 1", :count => 1
    end
    should "include extra locals information" do
      assert_have_selector 'p', :content => "Extra is bar"
    end
  end

  context 'for #partial method taking a path starting with forward slash' do
    setup { visit '/partial/foward_slash' }
    should "render partial without throwing an error" do
      assert_have_selector "h1", :content => "User name is John"
    end
  end

  context 'for #current_engine method' do
    should 'detect correctly current engine for a padrino application' do
      visit '/current_engine'
      assert_have_selector 'p.start', :content => "haml"
      assert_have_selector 'p.haml span',  :content => "haml"
      assert_have_selector 'p.erb span',   :content => "erb"
      assert_have_selector 'p.slim span',  :content => "slim"
      assert_have_selector 'p.end',   :content => "haml"
    end

    should "detect correctly current engine for explicit engine on partials" do
      visit '/explicit_engine'
      assert_have_selector 'p.start', :content => "haml"
      assert_have_selector 'p.haml span',  :content => "haml"
      assert_have_selector 'p.erb span',   :content => "erb"
      assert_have_selector 'p.slim span',  :content => "slim"
      assert_have_selector 'p.end',   :content => "haml"
    end
  end
end
