# Middleman is a static site renderer that provides all the conveniences of
# a modern web stack, like Ruby on Rails, while remaining focused on building
# the fastest, most-professional sites possible
#
# Install Middleman:
#
#     gem install middleman
#
# To accomplish its goals, Middleman supports provides access to:
# 
#### Command-line tool:
# * **middleman init**: A tool for creating to new static sites.
# * **middleman server**: A tool for rapidly developing your static site.
# * **middleman build**: A tool for exporting your site into optimized HTML, CSS & JS.
#
#### Tons of templating languages including:
# * ERB                        (.erb)
# * Interpolated String        (.str)
# * Sass                       (.sass)
# * Scss                       (.scss)
# * Haml                       (.haml)
# * Slim                       (.slim)
# * Less CSS                   (.less)
# * Builder                    (.builder)
# * Liquid                     (.liquid)
# * RDiscount                  (.markdown)
# * RedCloth                   (.textile)
# * RDoc                       (.rdoc)
# * Radius                     (.radius)
# * Markaby                    (.mab)
# * Nokogiri                   (.nokogiri)
# * Mustache                   (.mustache)
# * CoffeeScript               (.coffee)
#
#### Compile-time Optimiztions
# * Javascript Minifiers: YUI, Google Closure & UglifyJS
# * Smush.it Image Compression
# * CSS Minification
#
#### Robust Extensions:
# Add your own runtime and build-time features!
#
#### Next Steps:
# * [Visit the website]
# * [Read the wiki]
# * [Email the users group]
# * [Submit bug reports]
#
# [Visit the website]:     http://middlemanapp.com
# [Read the wiki]:         https://github.com/tdreyno/middleman/wiki
# [Email the users group]: https://convore.com/middleman/
# [Submit bug reports]:    https://github.com/tdreyno/middleman/issues

# Setup our load paths
libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# We're riding on Sinatra, so let's include it.
require "sinatra/base"

# Top-level Middleman object
module Middleman
  # Auto-load modules on-demand
  autoload :Base,        "middleman/base"
  autoload :Builder,     "middleman/builder"
  autoload :CLI,         "middleman/cli"
  autoload :Templates,   "middleman/templates"
  autoload :Guard,       "middleman/guard"
  
  # Custom Renderers
  module Renderers
    autoload :Haml,         "middleman/renderers/haml"
    autoload :Sass,         "middleman/renderers/sass"
    autoload :Slim,         "middleman/renderers/slim"
    autoload :Markdown,     "middleman/renderers/markdown"
    autoload :ERb,          "middleman/renderers/erb"
    autoload :CoffeeScript, "middleman/renderers/coffee_script"
    autoload :Liquid,       "middleman/renderers/liquid"
  end
  
  module CoreExtensions
    # File Change Notifier
    autoload :FileWatcher,   "middleman/core_extensions/file_watcher"
    
    # In-memory Sitemap
    autoload :Sitemap,     "middleman/core_extensions/sitemap"
    
    # Add Builder callbacks
    autoload :Builder,       "middleman/core_extensions/builder"
    
    # Add Rack::Builder.map support
    autoload :RackMap,       "middleman/core_extensions/rack_map"
    
    # Custom Feature API
    autoload :Features,      "middleman/core_extensions/features"
  
    # Asset Path Pipeline
    autoload :Assets,        "middleman/core_extensions/assets"
  
    # DefaultHelpers are the built-in dynamic template helpers.
    autoload :DefaultHelpers, "middleman/core_extensions/default_helpers"
  
    # Data looks at the data/ folder for YAML files and makes them available
    # to dynamic requests.
    autoload :Data,           "middleman/core_extensions/data"
    
    # Parse YAML from templates
    autoload :FrontMatter,    "middleman/core_extensions/front_matter"
    
    # Extended version of Padrino's rendering
    autoload :Rendering,      "middleman/core_extensions/rendering"
    
    # Compass framework for Sass
    autoload :Compass,         "middleman/core_extensions/compass"
    
    # Sprockets 2
    autoload :Sprockets,       "middleman/core_extensions/sprockets"
  
    # Pass custom options to views
    autoload :Routing,        "middleman/core_extensions/routing"
  end

  module Features
    # RelativeAssets allow any asset path in dynamic templates to be either
    # relative to the root of the project or use an absolute URL.
    autoload :RelativeAssets,      "middleman/features/relative_assets"

    # AssetHost allows you to setup multiple domains to host your static
    # assets. Calls to asset paths in dynamic templates will then rotate
    # through each of the asset servers to better spread the load.
    autoload :AssetHost,           "middleman/features/asset_host"

    # CacheBuster adds a query string to assets in dynamic templates to avoid
    # browser caches failing to update to your new content.
    autoload :CacheBuster,         "middleman/features/cache_buster"

    # AutomaticImageSizes inspects the images used in your dynamic templates
    # and automatically adds width and height attributes to their HTML
    # elements.
    autoload :AutomaticImageSizes, "middleman/features/automatic_image_sizes"

    # MinifyCss uses the YUI compressor to shrink CSS files
    autoload :MinifyCss,           "middleman/features/minify_css"

    # MinifyJavascript uses the YUI compressor to shrink JS files
    autoload :MinifyJavascript,    "middleman/features/minify_javascript"

    # Lorem provides a handful of helpful prototyping methods to generate
    # words, paragraphs, fake images, names and email addresses.
    autoload :Lorem,               "middleman/features/lorem"
    
    # Automatically convert filename.html files into filename/index.html
    autoload :DirectoryIndexes,    "middleman/features/directory_indexes"
    
    # Organize the sitemap as a tree
    autoload :SitemapTree,         "middleman/features/sitemap_tree"
  end
  
  EXTENSION_FILE = File.join("lib", "middleman_init.rb")
  def self.load_extensions_in_path
    extensions = rubygems_latest_specs.select do |spec|
      spec_has_file?(spec, EXTENSION_FILE)
    end
    
    extensions.each do |spec|
      require spec.name
      # $stderr.puts "require: #{spec.name}"
    end
  end
  
  def self.rubygems_latest_specs
    # If newer Rubygems
    if ::Gem::Specification.respond_to? :latest_specs
      ::Gem::Specification.latest_specs
    else
      ::Gem.source_index.latest_specs
    end
  end
  
  def self.spec_has_file?(spec, path)
    full_path = File.join(spec.full_gem_path, path)
    File.exists?(full_path)
  end
  
  def self.server(&block)
    sandbox = Class.new(Sinatra::Base)
    sandbox.register Base
    sandbox.class_eval(&block) if block_given?
    sandbox
  end
  
  def self.start_server(options={})
    opts = {
      :Port      => options[:port] || 4567,
      :AccessLog => []
    }
    
    app_class = options[:app] ||= ::Middleman.server.new
    opts[:app] = app_class
    opts[:server] = 'thin'

    server = ::Rack::Server.new(opts)
    server.start
    server
  end
end

require "middleman/version"
Middleman.load_extensions_in_path