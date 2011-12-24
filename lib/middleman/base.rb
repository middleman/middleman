# Built on Rack
require "rack"

# Using Tilt for templating
require "tilt"

# Simple callback library
require "middleman/vendor/hooks-0.2.0/lib/hooks"

# Use ActiveSupport JSON and Inflections
require "active_support"
require "active_support/json"
require "active_support/core_ext/string/inflections"
  
# Core Middleman Class
class Middleman::Base
  # Uses callbacks
  include Hooks
  
  # Before request hook
  define_hook :before
  
  # Ready (all loading and parsing of extensions complete) hook
  define_hook :ready
  
  class << self
    
    # Reset Rack setup
    #
    # @private
    def reset!
      @app = nil
      @prototype = nil
    end
    
    # The shared Rack instance being build
    #
    # @private
    # @return [Rack::Builder]
    def app
      @app ||= Rack::Builder.new
    end
    
    # Get the static instance
    #
    # @private
    # @return [Middleman::Base]
    def inst(&block)
      @inst ||= begin
        mm = new(&block)
        mm.run_hook :ready
        mm
      end
    end
    
    # Return built Rack app
    #
    # @private
    # @return [Rack::Builder]
    def to_rack_app(&block)
      inner_app = inst(&block)
      
      (@middleware || []).each do |m|
        app.use(m[0], *m[1], &m[2])
      end
      
      app.map("/") { run inner_app }
      
      (@mappings || []).each do |m|
        app.map(m[0], &m[1])
      end
      
      app
    end
    
    # Prototype app. Used in config.ru
    #
    # @private
    # @return [Rack::Builder]
    def prototype
      @prototype ||= to_rack_app
    end

    # Call prototype, use in config.ru
    #
    # @private
    def call(env)
      prototype.call(env)
    end
    
    # Use Rack middleware
    #
    # @param [Class] Middleware
    # @return [void]
    def use(middleware, *args, &block)
      @middleware ||= []
      @middleware << [middleware, args, block]
    end
    
    # Add Rack App mapped to specific path
    #
    # @param [String] Path to map
    # @return [void]
    def map(map, &block)
      @mappings ||= []
      @mappings << [map, block]
    end
    
    # Mix-in helper methods. Accepts either a list of Modules
    # and/or a block to be evaluated
    # @return [void]
    def helpers(*extensions, &block)
      class_eval(&block)   if block_given?
      include(*extensions) if extensions.any?
    end
    
    # Access class-wide defaults
    #
    # @private
    # @return [Hash] Hash of default values
    def defaults
      @defaults ||= {}
    end
    
    # Set class-wide defaults
    #
    # @param [Symbol] Unique key name
    # @param Default value
    # @return [void]
    def set(key, value)
      @defaults ||= {}
      @defaults[key] = value
    end
  end
  
  # Set attributes (global variables)
  #
  # @param [Symbol] Name of the attribue
  # @param Attribute value
  # @return [void]
  def set(key, value=nil, &block)
    setter = "#{key}=".to_sym
    self.class.send(:attr_accessor, key) if !respond_to?(setter)
    value = block if block_given?
    send(setter, value)
  end
  
  # Root project directory (overwritten in middleman build/server)
  # @return [String]
  set :root,        ENV['MM_ROOT'] || Dir.pwd
  
  # Name of the source directory
  # @return [String]
  set :source,      "source"
  
  # Middleman environment. Defaults to :development, set to :build by the build process
  # @return [String]
  set :environment, (ENV['MM_ENV'] && ENV['MM_ENV'].to_sym) || :development
  
  # Whether logging is active, disabled by default
  # @return [String]
  set :logging, false

  # Which file should be used for directory indexes
  # @return [String]
  set :index_file,  "index.html"

  # Location of javascripts within source. Used by Sprockets.
  # @return [String]
  set :js_dir,      "javascripts"
  
  # Location of stylesheets within source. Used by Compass.
  # @return [String]
  set :css_dir,     "stylesheets"
  
  # Location of images within source. Used by HTML helpers and Compass.
  # @return [String]
  set :images_dir,  "images"

  # Where to build output files
  # @return [String]
  set :build_dir,   "build"
  
  # Default prefix for building paths. Used by HTML helpers and Compass.
  # @return [String]
  set :http_prefix, "/"

  # Whether to catch and display exceptions
  # @return [Boolean]
  set :show_exceptions, true

  # Automatically loaded extensions
  # @return [Array<Symbol>]
  set :default_extensions, [
    :lorem
  ]

  # Default layout name
  # @return [String, Symbold]
  set :layout, :_auto_layout
  
  # Activate custom features and extensions
  include Middleman::CoreExtensions::Extensions
  
  # Handle exceptions
  register Middleman::CoreExtensions::ShowExceptions
    
  # Add Builder Callbacks
  register Middleman::CoreExtensions::Builder
  
  # Add Guard Callbacks
  register Middleman::CoreExtensions::FileWatcher
  
  # Activate Data package
  register Middleman::CoreExtensions::Data
  
  # Setup custom rendering
  register Middleman::CoreExtensions::Rendering
  
  # Sitemap
  register Middleman::CoreExtensions::Sitemap
  
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
  
  # Built-in Extensions
  Middleman::Extensions.register(:asset_host) { 
    Middleman::Extensions::AssetHost }
  Middleman::Extensions.register(:automatic_image_sizes) {
    Middleman::Extensions::AutomaticImageSizes }
  Middleman::Extensions.register(:cache_buster) { 
    Middleman::Extensions::CacheBuster }
  Middleman::Extensions.register(:directory_indexes) {
    Middleman::Extensions::DirectoryIndexes }
  Middleman::Extensions.register(:lorem) { 
    Middleman::Extensions::Lorem }
  Middleman::Extensions.register(:minify_css) { 
    Middleman::Extensions::MinifyCss }
  Middleman::Extensions.register(:minify_javascript) {
    Middleman::Extensions::MinifyJavascript }
  Middleman::Extensions.register(:relative_assets) {
    Middleman::Extensions::RelativeAssets }
  
  # Backwards-compatibility with old request.path signature
  attr :request
  
  # Accessor for current path
  # @return [String]
  def current_path
    @_current_path
  end
  
  # Set the current path
  #
  # @param [String] path The new current path
  # @return [void]
  def current_path=(path)
    @_current_path = path
    @request = Thor::CoreExt::HashWithIndifferentAccess.new({ :path => path })
  end
  
  # Initialize the Middleman project
  def initialize(&block)
    # Current path defaults to nil, used in views.
    self.current_path = nil
    
    # Clear the static class cache
    cache.clear
    
    # Setup the default values from calls to set before initialization
    self.class.superclass.defaults.each { |k,v| set(k,v) }
    
    # Evaluate a passed block if given
    instance_exec(&block) if block_given?
    
    # Build expanded source path once paths have been parsed
    set :source_dir, File.join(root, source)
    
    super
  end
  
  # Shared cache instance
  #
  # @private
  # @return [Middleman::Cache] The cache
  def self.cache
    @_cache ||= ::Middleman::Cache.new
  end
  delegate :cache, :to => :"self.class"
  
  # Rack env
  attr :env
  
  # Rack request
  # @return [Rack::Request]
  attr :req
  
  # Rack response
  # @return [Rack::Response]
  attr :res
  
  # Rack Interface
  #
  # @private
  # @param Rack environment
  def call(env)
    # Store environment, request and response for later
    @env = env
    @req = Rack::Request.new(env)
    @res = Rack::Response.new

    puts "== Request: #{env["PATH_INFO"]}" if logging?

    if env["PATH_INFO"] == "/__middleman__" && env["REQUEST_METHOD"] == "POST"
      if req.params.has_key?("change")
        file_did_change(req.params["change"])
      elsif req.params.has_key?("delete")
        file_did_delete(req.params["delete"])
      end
      
      res.status = 200
      return res.finish
    end
    
    # Catch :halt exceptions and use that response if given
    catch(:halt) do
      process_request

      res.status = 404
      res.finish
    end
  end
  
  # Halt the current request and return a response
  #
  # @private
  # @param [String] Reponse value
  def halt(response)
    throw :halt, response
  end
  
  # Whether we're in development mode
  # @return [Boolean] If we're in dev mode
  def development?; environment == :development; end
  
  # Whether we're in build mode
  # @return [Boolean] If we're in build mode
  def build?; environment == :build; end
  
  # Core repsonse method. We process the request, check with the sitemap,
  # and return the correct file, response or status message.
  #
  # @private
  def process_request
    # Normalize the path and add index if we're looking at a directory
    @original_path = env["PATH_INFO"].dup
    @request_path  = full_path(env["PATH_INFO"].gsub("%20", " "))
    
    # Run before callbacks
    run_hook :before
    
    # Return 404 if not in sitemap
    return not_found unless sitemap.exists?(@request_path)
    
    # Get the page object for this path
    sitemap_page = sitemap.page(@request_path)
    
    # Return 404 if this path is specifically ignored
    return not_found if sitemap_page.ignored?

    # If this path is a static file, send it immediately
    return send_file(sitemap_page.source_file) unless sitemap_page.template?
    
    # Set the current path for use in helpers
    self.current_path = @request_path.dup
      
    # Set a HTTP content type based on the request's extensions
    content_type sitemap_page.mime_type
    
    begin
      # Write out the contents of the page
      res.write sitemap_page.render
      
      # Valid content is a 200 status
      res.status = 200
    rescue Middleman::CoreExtensions::Rendering::TemplateNotFound => e
      res.write "Error: #{e.message}"
      res.status = 500
    end
    
    # End the request
    puts "== Finishing Request: #{self.current_path}" if logging?
    halt res.finish
  end

  # Backwards compatibilty with old Sinatra template interface
  #
  # @return [Middleman::Base]
  def settings
    self
  end

  # Whether we're logging
  #
  # @return [Boolean] If we're logging
  def logging?
    logging
  end
  
  # Expand a path to include the index file if it's a directory
  #
  # @private
  # @param [String] path Request path
  # @return [String] Path with index file if necessary
  def full_path(path)
    cache.fetch(:full_path, path) do
      parts = path ? path.split('/') : []
      if parts.last.nil? || parts.last.split('.').length == 1
        path = File.join(path, index_file) 
      end
      "/" + path.sub(%r{^/}, '')
    end
  end
  
  # Add a new mime-type for a specific extension
  #
  # @param [Symbol] type File extension
  # @param [String] value Mime type
  # @return [void]
  def mime_type(type, value=nil)
    return type if type.nil? || type.to_s.include?('/')
    type = ".#{type}" unless type.to_s[0] == ?.
    return ::Rack::Mime.mime_type(type, nil) unless value
    ::Rack::Mime::MIME_TYPES[type] = value
  end
  
protected

  # Halt request and return 404
  def not_found
    @res.status == 404
    @res.write "<html><body><h1>File Not Found</h1><p>#{@request_path}</p></body>"
    @res.finish
  end
  
  delegate :helpers, :use, :map, :to => :"self.class"
  
  # Immediately send static file
  #
  # @param [String] path File to send
  def send_file(path)
    extension = File.extname(path)
    matched_mime = mime_type(extension)
    matched_mime = "application/octet-stream" if matched_mime.nil?
    content_type matched_mime
    
    file      = ::Rack::File.new nil
    file.path = path
    response = file.serving(env)
    response[1]['Content-Encoding'] = 'gzip' if %w(.svgz).include?(extension)
    halt response
  end
  
  # Set the content type for the current request
  #
  # @param [String] type Content type
  # @param [Hash] params
  # @return [void]
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
end