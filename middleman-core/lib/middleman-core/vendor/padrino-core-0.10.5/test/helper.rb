ENV['PADRINO_ENV'] = 'test'
PADRINO_ROOT = File.dirname(__FILE__) unless defined?(PADRINO_ROOT)

require File.expand_path('../../../load_paths', __FILE__)
require File.expand_path('../mini_shoulda', __FILE__)
require 'padrino-core'
require 'json'
require 'rack/test'
require 'rack'

# Rubies < 1.9 don't handle hashes in the properly order so to prevent
# this issue for now we remove extra values from mimetypes.
Rack::Mime::MIME_TYPES.delete(".xsl") # In this way application/xml respond only to .xml

class Sinatra::Base
  # Allow assertions in request context
  include MiniTest::Assertions
end

class MiniTest::Spec
  include Rack::Test::Methods

  # Sets up a Sinatra::Base subclass defined with the block
  # given. Used in setup or individual spec methods to establish
  # the application.
  def mock_app(base=Padrino::Application, &block)
    @app = Sinatra.new(base, &block)
  end

  def app
    Rack::Lint.new(@app)
  end

  # Asserts that a file matches the pattern
  def assert_match_in_file(pattern, file)
    assert File.exist?(file), "File '#{file}' does not exist!"
    assert_match pattern, File.read(file)
  end

  # Delegate other missing methods to response.
  def method_missing(name, *args, &block)
    if response && response.respond_to?(name)
      response.send(name, *args, &block)
    else
      super(name, *args, &block)
    end
  rescue Rack::Test::Error # no response yet
    super(name, *args, &block)
  end

  alias :response :last_response

  def create_template(name, content, options={})
    FileUtils.mkdir_p(File.dirname(__FILE__) + "/views")
    FileUtils.mkdir_p(File.dirname(__FILE__) + "/views/layouts")
    path  = "/views/#{name}"
    path += ".#{options.delete(:locale)}" if options[:locale].present?
    path += ".#{options[:format]}" if options[:format].present?
    path += ".erb" unless options[:format].to_s =~ /haml|rss|atom/
    path += ".builder" if options[:format].to_s =~ /rss|atom/
    file  = File.dirname(__FILE__) + path
    File.open(file, 'w') { |io| io.write content }
    file
  end
  alias :create_view   :create_template
  alias :create_layout :create_template

  def remove_views
    FileUtils.rm_rf(File.dirname(__FILE__) + "/views")
  end

  def with_template(name, content, options={})
    # Build a temp layout
    template = create_template(name, content, options)
    yield
  ensure
    # Remove temp layout
    File.unlink(template) rescue nil
    remove_views
  end
  alias :with_view   :with_template
  alias :with_layout :with_template
end
