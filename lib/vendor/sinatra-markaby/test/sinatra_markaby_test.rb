require File.dirname(__FILE__) + '/test_helper'

class SinatraMarkabyTest < Test::Unit::TestCase
  def markaby_app(&block)
    mock_app {
      use_in_file_templates!
      helpers Sinatra::Markaby
      set :views, File.dirname(__FILE__) + '/views'
      get '/', &block
    }
    get '/'
  end

  def test_renders_inline_strings
    markaby_app { markaby 'mab.p "Hello shrimp!"' }
    assert last_response.ok?
    assert_equal '<p>Hello shrimp!</p>', last_response.body
  end

  def test_renders_inline_blocks
    markaby_app {
      @name = 'Frank & Mary'
      markaby do |mab|
        mab.p "Hello #{@name}!"
      end
    }
    assert last_response.ok?
    assert_equal '<p>Hello Frank &amp; Mary!</p>', last_response.body
  end

  def test_renders_markaby_files_in_views_path
    markaby_app {
      @name = 'World'
      markaby :hello
    }
    assert last_response.ok?
    assert_equal '<p>Hello, World!</p>', last_response.body
  end

  def test_renders_in_file_template
    markaby_app {
      @name = 'Joe'
      markaby :in_file
    }
    assert last_response.ok?
    assert_equal '<p>Hey Joe</p>', last_response.body
  end

  def test_renders_with_layout
    markaby_app {
      @name = 'with Layout'
      markaby :hello, :layout => :html
    }
    assert last_response.ok?
    assert_equal '<html><head><meta content="text/html; charset=utf-8" http-equiv="Content-Type"/><title>Hello</title></head><body><p>Hello, with Layout!</p></body></html>', last_response.body
  end

  def test_raises_error_if_template_not_found
    mock_app {
      helpers Sinatra::Markaby
      set :environment, :test
      set :raise_errors, true
      get('/') { markaby :no_such_template }
    }
    assert_raises(Errno::ENOENT) { get('/') }
  end
end

__END__

@@ in_file
mab.p "Hey #{@name}"
