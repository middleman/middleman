require File.dirname(__FILE__) + '/test_helper'

class SinatraMarukuTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def maruku_app(&block)
    mock_app {
      set :views, File.dirname(__FILE__) + '/views'      
      helpers Sinatra::Maruku
      set :show_exceptions, false
      get '/', &block
    }
    get '/'
  end
  
  def test_renders_inline_strings
    maruku_app { maruku 'hello world' }
    assert last_response.ok?
    assert_equal "<p>hello world</p>", last_response.body
  end
  
  def test_renders_inline_erb_string
    maruku_app { maruku '<%= 1 + 1 %>' }
    assert last_response.ok?
    assert_equal "<p>2</p>", last_response.body
  end

  def test_renders_files_in_views_path
    maruku_app { maruku :hello }
    assert last_response.ok?
    assert_equal "<h1 id='hello_world'>hello world</h1>", last_response.body
  end
  
  def test_takes_locals_option
    maruku_app {
      locals = {:foo => 'Bar'}
      maruku "<%= foo %>", :locals => locals
    }
    assert last_response.ok?
    assert_equal "<p>Bar</p>", last_response.body
  end

  def test_renders_with_inline_layouts
    maruku_app {
      maruku 'Sparta', :layout => 'THIS. IS. <%= yield.upcase %>' 
    }
    assert last_response.ok?
    assert_equal "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<!DOCTYPE html PUBLIC\n    \"-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN\"\n    \"http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd\">\n<html xmlns:svg='http://www.w3.org/2000/svg' xml:lang='en' xmlns='http://www.w3.org/1999/xhtml'>\n<head><meta content='application/xhtml+xml;charset=utf-8' http-equiv='Content-type' /><title></title></head>\n<body>\n<p>THIS. IS. <P>SPARTA</P></p>\n</body></html>", last_response.body
  end

  def test_renders_with_file_layouts
    maruku_app {
      maruku 'hello world', :layout => :layout2
    }
    assert last_response.ok?
    assert_equal "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<!DOCTYPE html PUBLIC\n    \"-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN\"\n    \"http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd\">\n<html xmlns:svg='http://www.w3.org/2000/svg' xml:lang='en' xmlns='http://www.w3.org/1999/xhtml'>\n<head><meta content='application/xhtml+xml;charset=utf-8' http-equiv='Content-type' /><title></title></head>\n<body>\n<p>erb layout <p>hello world</p></p>\n</body></html>", last_response.body
  end

  def test_renders_erb_with_blocks
    mock_app {
      set :views, File.dirname(__FILE__) + '/views'      
      helpers Sinatra::Maruku
      
      def container
        yield
      end
      def is
        "THIS. IS. SPARTA!"
      end
      
      get '/' do
        maruku '<% container do %> <%= is %> <% end %>'
      end
    }
    
    get '/'
    assert last_response.ok?
    assert_equal "<p>THIS. IS. SPARTA!</p>", last_response.body
  end
  
  def test_raises_error_if_template_not_found
    mock_app {
      set :views, File.dirname(__FILE__) + '/views'      
      helpers Sinatra::Maruku
      set :show_exceptions, false
      
      get('/') { maruku :no_such_template }
    }
    assert_raise(Errno::ENOENT) { get('/') }
  end
end
