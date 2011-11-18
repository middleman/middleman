require "rack"
require "tilt"
require "i18n"
require "hooks"
require "active_support"
require "active_support/json"
require "active_support/core_ext/string/inflections"
# require "active_support/core_ext/class/attribute_accessors"

class Middleman::Base
  include Hooks
  define_hook :build_config
  define_hook :development_config
  
  class << self
    def reset!
      @app = nil
      @prototype = nil
    end
    
    def app
      @app ||= Rack::Builder.new
    end
    
    def prototype
      @prototype ||= app.to_app
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
    
    def before_processing(name=:unnamed, idx=-1, &block)
      @before_processes ||= []
      @before_processes.insert(idx, [name, block])
    end
    
    def execute_before_processing!(inst, resolved_template)
      @before_processes ||= []
      
      @before_processes.all? do |name, block|
        inst.instance_exec(resolved_template, &block)
      end
    end
    
    def configure(env, &block)
      send("#{env}_config", &block)
    end
  end
  
  def set(key, value)
    setter = "#{key}=".to_sym
    self.class.send(:attr_accessor, key) if !respond_to?(setter)
    send(setter, value)
  end
  
  def configure(env, &block)
    self.class.configure(env, &block)
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
  
  define_hook :initialized
  def initialize(&block)
    self.class.superclass.defaults.each do |k, v|
      set(k, v)
    end
    
    set :source_dir, File.join(root, source)
      
    super
    
    run_hook :initialized
  end
  
  def call(env)
    @env = env
    @req = Rack::Request.new(env)
    @res = Rack::Response.new

    process_request
  end

  # Custom 404 handler (to be styled)
  # app.error Sinatra::NotFound do
  #   content_type 'text/html'
  #   "<html><body><h1>File Not Found</h1><p>#{request.path_info}</p></body>"
  # end
  
  # Convenience methods to check if we're in a mode
  def development?; environment == :development; end
  def build?; environment == :build; end
  
  # Internal method to look for templates and evaluate them if found
  def process_request
    # Normalize the path and add index if we're looking at a directory
    original_path = @env["PATH_INFO"].dup
    request_path  = full_path(@env["PATH_INFO"].gsub("%20", " "))
  
    # return not_found if sitemap.ignored_path?(request_path)
    
    # if sitemap.path_is_proxy?(request_path)
    #   request["is_proxy"] = true
    #   request_path = "/" + sitemap.path_target(request_path)
    # end
    
    found_template = resolve_template(request_path)
    return not_found unless found_template
    
    path, engine = found_template
    
    # Static File
    return send_file(path) if engine.nil?
    
    # return unless settings.execute_before_processing!(self, found_template)
    
    # context = settings.sitemap.get_context(original_path) || {}
    # 
    options = {}
    # options = context.has_key?(:options) ? context[:options] : {}
    # options.merge!(request['custom_options'] || {})
    # 

    local_layout = if options.has_key?(:layout)
      options[:layout]
    else
      layout
    end
    
    # if context.has_key?(:block) && context[:block]
    #   instance_eval(&context[:block])
    # end

    # locals = request['custom_locals'] || {}
    locals = {}
    
    # content_type mime_type(File.extname(request_path))
    @res.status = 200
    
    output = if layout
      layout_engine = if options.has_key?(:layout_engine)
        options[:layout_engine]
      else
        engine
      end
      
      layout_path, *etc = resolve_template(layout, :preferred_engine => layout_engine)
    
      render(layout_path, locals) do
        render(path, locals)
      end
    else
      render(path, locals)
    end
    
    @res.write output
    @res.finish
  end
  
public
  
protected

  def full_path(path)
    parts = path ? path.split('/') : []
    if parts.last.nil? || parts.last.split('.').length == 1
      path = File.join(path, index_file) 
    end
    "/" + path.sub(%r{^/}, '')
  end
  
  def not_found
    @res.status == 404
    @res.write "<html><body><h1>File Not Found</h1><p>#{@env["PATH_INFO"]}</p></body>"
    @res.finish
  end
  
  def resolve_template(request_path, options={})
    request_path = request_path.to_s
    @_resolved_templates ||= {}
    
    if !@_resolved_templates.has_key?(request_path)
      relative_path = request_path.sub(%r{^/}, "")
      on_disk_path  = File.expand_path(relative_path, source_dir)
      
      preferred_engine = if options.has_key?(:preferred_engine)
        extension_class = Tilt[options[:preferred_engine]]
        matched_exts = []
        
        # TODO: Cache this
        Tilt.mappings.each do |ext, engines|
          next unless engines.include? extension_class
          matched_exts << ext
        end
        
        "{" + matched_exts.join(",") + "}"
      else
        "*"
      end
      
      path_with_ext = on_disk_path + "." + preferred_engine
  
      found_engine = nil
      found_path = Dir[path_with_ext].find do |path|
        ::Tilt[path]
      end
  
      result = if found_path || File.exists?(on_disk_path)
        engine = found_path ? File.extname(found_path)[1..-1].to_sym : nil
        [ found_path || on_disk_path, engine ]
      else
        false
      end
      
      @_resolved_templates[request_path] = result
    end
    
    @_resolved_templates[request_path]
  end
  
  def extensionless_path(file)
    @_extensionless_path_cache ||= {}
    
    if @_extensionless_path_cache.has_key?(file)
      @_extensionless_path_cache[file]
    else
      path = file.dup
      end_of_the_line = false
      while !end_of_the_line
        file_extension = File.extname(path)
  
        if ::Tilt.mappings.has_key?(file_extension.gsub(/^\./, ""))
          path = path.sub(file_extension, "")
        else
          end_of_the_line = true
        end
      end
      
      @_extensionless_path_cache[file] = path
      path
    end
  end
  
  def send_file(path)
    
    #       matched_mime = mime_type(File.extname(request_path))
    #       matched_mime = "application/octet-stream" if matched_mime.nil?
    #       content_type matched_mime
    
    file      = ::Rack::File.new nil
    file.path = path
    file.serving# env
  end
  
  def render(path, locals = {}, options = {}, &block)
    path = path.to_s
    template = ::Tilt.new(path, 1, options)
    template.render(self, locals, &block)
  end
  
  def logging?
    logging
  end
end