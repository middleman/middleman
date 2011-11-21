require "rack"
require "tilt"
require "i18n"
require "middleman/vendor/hooks-0.2.0/lib/hooks"

require "active_support"
require "active_support/json"
require "active_support/core_ext/string/inflections"

class Middleman::Base
  include Hooks
  define_hook :before
  define_hook :ready
  define_hook :initialized
  
  class << self
    def reset!
      @app = nil
      @prototype = nil
    end
    
    def app
      @app ||= Rack::Builder.new
    end
    
    def inst(&block)
      @inst ||= new(&block)
    end
    
    def to_rack_app(&block)
      inner_app = inst(&block)
      app.map("/") { run inner_app }
      app
    end
    
    def prototype
      @prototype ||= to_rack_app
    end

    def call(env)
      prototype.call(env)
    end
    
    def use(middleware, *args, &block)
      app.use(middleware, *args, &block)
    end
    
    def map(map, &block)
      app.map(map, &block)
    end
    
    def helpers(*extensions, &block)
      class_eval(&block)   if block_given?
      include(*extensions) if extensions.any?
    end
    
    def defaults
      @defaults ||= {}
    end
    
    def set(key, value)
      @defaults ||= {}
      @defaults[key] = value
    end
    
    def asset_stamp; false; end
  end
  
  def set(key, value=nil, &block)
    setter = "#{key}=".to_sym
    self.class.send(:attr_accessor, key) if !respond_to?(setter)
    value = block if block_given?
    send(setter, value)
  end
  
  # Basic Sinatra config
  set :root,        Dir.pwd
  set :source,      "source"
  set :environment, (ENV['MM_ENV'] && ENV['MM_ENV'].to_sym) || :development
  set :logging, false

  # Middleman-specific options
  set :index_file,  "index.html"  # What file responds to folder requests
                                  # Such as the homepage (/) or subfolders (/about/)

  # These directories are passed directly to Compass
  set :js_dir,      "javascripts" # Where to look for javascript files
  set :css_dir,     "stylesheets" # Where to look for CSS files
  set :images_dir,  "images"      # Where to look for images

  set :build_dir,   "build"       # Which folder are builds output to
  set :http_prefix, nil           # During build, add a prefix for absolute paths

  set :views, "source"
  
  set :default_features, [
    :lorem,
    # :sitemap_tree
  ]

  # Default layout name
  set :layout, :layout
  
  # Activate custom features and extensions
  include Middleman::CoreExtensions::Features
    
  # Add Builder Callbacks
  register Middleman::CoreExtensions::Builder
  
  # Add Guard Callbacks
  register Middleman::CoreExtensions::FileWatcher
  
  # Sitemap
  register Middleman::CoreExtensions::Sitemap
  
  # Activate Data package
  register Middleman::CoreExtensions::Data
  
  # Setup custom rendering
  register Middleman::CoreExtensions::Rendering
  
  # Compass framework
  register Middleman::CoreExtensions::Compass

  # Sprockets asset handling
  register Middleman::CoreExtensions::Sprockets
  
  # Setup asset path pipeline
  register Middleman::CoreExtensions::Assets
  
  # Activate built-in helpers
  register Middleman::CoreExtensions::DefaultHelpers
  
  # with_layout and page routing
  register Middleman::CoreExtensions::Routing
  
  # Parse YAML from templates
  register Middleman::CoreExtensions::FrontMatter
  
  def initialize(&block)
    @current_path = nil
    
    self.class.superclass.defaults.each do |k, v|
      set(k, v)
    end
    
    instance_exec(&block) if block_given?
    
    set :source_dir, File.join(root, source)
      
    super
    
    run_hook :initialized
  end
  
  def cache
    @_cache ||= ::Middleman::Cache.new
  end
  
  attr :env
  attr :req
  attr :res
  
  # Rack Interface
  def call(env)
    @env = env
    @req = Rack::Request.new(env)
    @res = Rack::Response.new

    catch(:halt) do
      process_request

      res.status = 404
      res.finish
    end
  end
  
  def halt(response)
    throw :halt, response
  end
  
  # Convenience methods to check if we're in a mode
  def development?; environment == :development; end
  def build?; environment == :build; end
  
  # Internal method to look for templates and evaluate them if found
  def process_request
    # Normalize the path and add index if we're looking at a directory
    @original_path = env["PATH_INFO"].dup
    @request_path  = full_path(env["PATH_INFO"].gsub("%20", " "))
    
    run_hook :before
    
    return not_found unless sitemap.exists?(@request_path)
    
    sitemap_page = sitemap.page(@request_path)
    return not_found if sitemap_page.ignored?

    # Static File
    return send_file(sitemap_page.source_file) unless sitemap_page.template?
    
    @current_path = @request_path.dup
      
    content_type sitemap_page.mime_type
    res.status = 200
    rqp = @request_path
    res.write sitemap_page.render
    halt res.finish
  end
  
public

  def logging?
    logging
  end

  attr_accessor :current_path
  
  def full_path(path)
    cache.fetch(:full_path, path) do
      parts = path ? path.split('/') : []
      if parts.last.nil? || parts.last.split('.').length == 1
        path = File.join(path, index_file) 
      end
      "/" + path.sub(%r{^/}, '')
    end
  end
  
  def not_found
    @res.status == 404
    @res.write "<html><body><h1>File Not Found</h1><p>#{@request_path}</p></body>"
    @res.finish
  end
  
  def send_file(path)
    matched_mime = mime_type(File.extname(path))
    matched_mime = "application/octet-stream" if matched_mime.nil?
    content_type matched_mime
    
    file      = ::Rack::File.new nil
    file.path = path
    halt file.serving(env)
  end
  
  # Sinatra/Padrino render method signature
  def render(engine, data, options={}, locals={}, &block)
    if sitemap.exists?(data)
      sitemap.page(data).render(options, locals, &block)
    else
      throw "Could not find file to render: #{data}"
    end
  end
  
  def mime_type(type, value=nil)
    return type if type.nil? || type.to_s.include?('/')
    type = ".#{type}" unless type.to_s[0] == ?.
    return ::Rack::Mime.mime_type(type, nil) unless value
    ::Rack::Mime::MIME_TYPES[type] = value
  end
  
  def content_type(type = nil, params={})
    return res['Content-Type'] unless type
    default = params.delete :default
    mime_type = mime_type(type) || default
    throw "Unknown media type: %p" % type if mime_type.nil?
    mime_type = mime_type.dup
    unless params.include? :charset
      params[:charset] = params.delete('charset') || "utf-8"
    end
    params.delete :charset if mime_type.include? 'charset'
    unless params.empty?
      mime_type << (mime_type.include?(';') ? ', ' : ';')
      mime_type << params.map { |kv| kv.join('=') }.join(', ')
    end
    res['Content-Type'] = mime_type
  end
  
  # Forward to class level
  def helpers(*extensions, &block)
    self.class.helpers(*extensions, &block)
  end
  
  def use(middleware, *args, &block)
    self.class.use(middleware, *args, &block)
  end
  
  def map(map, &block)
    self.class.map(map, &block)
  end
end