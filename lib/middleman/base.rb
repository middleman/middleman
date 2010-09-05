# We're riding on Sinatra, so let's include it
require "sinatra/base"
require "sinatra/content_for"

class Sinatra::Request
  attr_accessor :layout
end

module Middleman
  class Base < Sinatra::Base
    set :app_file, __FILE__
    set :root, ENV["MM_DIR"] || Dir.pwd
    set :reload, false
    set :sessions, false
    set :logging, false
    set :environment, ENV['MM_ENV'] || :development
    set :index_file, "index.html"
    set :js_dir, "javascripts"
    set :css_dir, "stylesheets"
    set :images_dir, "images"
    set :fonts_dir, "fonts"
    set :build_dir, "build"
    set :http_prefix, nil
    
    helpers Sinatra::ContentFor
    
    set :features, []
    def self.enable(*opts)
      set :features, (self.features << opts).flatten
      super
    end
    
    def self.disable(*opts)
      current = self.features
      current -= opts.flatten
      set :features, current
      super
    end
    
    def self.set(option, value=self, &block)
      if block_given?
        value = Proc.new { block }
      end
      
      super(option, value, &nil)
    end
    
    @@afters = []
    def self.after_feature_init(&block)
      @@afters << block
    end
    
    # Rack helper for adding mime-types during local preview
    def self.mime(ext, type)
      ext = ".#{ext}" unless ext.to_s[0] == ?.
      ::Rack::Mime::MIME_TYPES[ext.to_s] = type
    end
    
    @@layout = nil
    def self.page(url, options={}, &block)
      layout = @@layout
      layout = options[:layout] if !options[:layout].nil?
      
      get(url) do
        return yield if block_given?
        process_request(layout)
      end
    end
    
    def self.with_layout(layout, &block)
      @@layout = layout
      class_eval(&block) if block_given?
    ensure
      @@layout = nil
    end
    
    def self.enabled?(name)
      name = (name.to_s << "?").to_sym
      self.respond_to?(name) && self.send(name)
    end
    
    def enabled?(name)
      self.class.enabled?(name)
    end

    # This will match all requests not overridden in the project's init.rb
    not_found do
      process_request
    end
    
  private
    def process_request(layout = :layout)
      # Normalize the path and add index if we're looking at a directory
      path = request.path
      path << settings.index_file if path.match(%r{/$})
      path.gsub!(%r{^/}, '')

      template_path = locate_template_file(path)
      if template_path
        content_type mime_type(File.extname(path)), :charset => 'utf-8'
        
        renderer = Middleman::Renderers.get_method(template_path)
        if respond_to? renderer
          status 200
          return send(renderer, path.to_sym, { :layout => layout })
        end
      end
      
      status 404
    end
    
    def locate_template_file(path)
      template_path = File.join(settings.views, "#{path}.*")
      Dir.glob(template_path).first
    end
  end
end

require "middleman/assets"
require "middleman/renderers"
require "middleman/features"

# The Rack App
class Middleman::Base
  def self.new(*args, &block)
    # Check for and evaluate local configuration
    local_config = File.join(self.root, "init.rb")
    if File.exists? local_config
      puts "== Reading:  Local config" if logging?
      Middleman::Base.class_eval File.read(local_config)
      set :app_file, File.expand_path(local_config)
    end
    
    # loop over enabled feature
    features.flatten.each do |feature_name|
      next unless send(:"#{feature_name}?")
      $stderr.puts "== Enabling: #{feature_name.to_s.capitalize}" if logging?
      Middleman::Features.run(feature_name, self)
    end
    
    use ::Rack::ConditionalGet if environment == :development
    
    @@afters.each { |block| class_eval(&block) }
    
    super
  end
end
