require "rbconfig"

# Using Thor's indifferent hash access
require "thor"

require "active_support"

# Setup our load paths
libdir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

class String
  def camelize
    self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end
end

# Simple callback library
require "middleman-core/vendor/hooks-0.2.0/lib/hooks"

# Top-level Middleman object
module Middleman
  WINDOWS = !!(RUBY_PLATFORM =~ /(mingw|bccwin|wince|mswin32)/i)
  JRUBY   = !!(RbConfig::CONFIG["RUBY_INSTALL_NAME"] =~ /^jruby/i)
  
  # Auto-load modules on-demand
  autoload :Base,           "middleman-core/base"
  autoload :Cache,          "middleman-core/cache"
  autoload :Templates,      "middleman-core/templates"
  autoload :Guard,          "middleman-core/guard"
  
  module Cli
    autoload :Base,         "middleman-core/cli"
    autoload :Build,        "middleman-core/cli/build"
    autoload :Init,         "middleman-core/cli/init"
    autoload :Server,       "middleman-core/cli/server"
  end
  
  # Custom Renderers
  module Renderers
    autoload :ERb,          "middleman-core/renderers/erb"
  end
  
  module Sitemap
    autoload :Store,        "middleman-core/sitemap/store"
    autoload :Page,         "middleman-core/sitemap/page"
    autoload :Template,     "middleman-core/sitemap/template"
  end
  
  module CoreExtensions
    # File Change Notifier
    autoload :FileWatcher,    "middleman-core/core_extensions/file_watcher"
    
    # In-memory Sitemap
    autoload :Sitemap,        "middleman-core/core_extensions/sitemap"
    
    # Add Builder callbacks
    autoload :Builder,        "middleman-core/core_extensions/builder"
    
    # Custom Feature API
    autoload :Extensions,     "middleman-core/core_extensions/extensions"
  
    # Asset Path Pipeline
    autoload :Assets,         "middleman-core/core_extensions/assets"
  
    # Data looks at the data/ folder for YAML files and makes them available
    # to dynamic requests.
    autoload :Data,           "middleman-core/core_extensions/data"
    
    # Parse YAML from templates
    autoload :FrontMatter,    "middleman-core/core_extensions/front_matter"
    
    # DefaultHelpers are the built-in dynamic template helpers.
    autoload :DefaultHelpers, "middleman-core/core_extensions/default_helpers"

    # Extended version of Padrino's rendering
    autoload :Rendering,      "middleman-core/core_extensions/rendering"
    
    # Pass custom options to views
    autoload :Routing,        "middleman-core/core_extensions/routing"
    
    # Catch and show exceptions at the Rack level
    autoload :ShowExceptions, "middleman-core/core_extensions/show_exceptions"
  end
  
  module Extensions
    # Provide Apache-style index.html files for directories
    autoload :DirectoryIndexes, "middleman-core/extensions/directory_indexes"

    # Lorem provides a handful of helpful prototyping methods to generate
    # words, paragraphs, fake images, names and email addresses.
    autoload :Lorem,            "middleman-core/extensions/lorem"
  end
  
  module Extensions  
    class << self
      def registered
        @_registered ||= {}
      end

      def register(name, namespace=nil, version=nil, &block)
        # If we've already got a matching extension that passed the 
        # version check, bail out.
        return if registered.has_key?(name.to_sym) && 
        !registered[name.to_sym].is_a?(String)

        if block_given?
          version = namespace
        end

        passed_version_check = true
        if !version.nil?
          requirement = ::Gem::Requirement.create(version)
          if !requirement.satisfied_by?(Middleman::GEM_VERSION)
            passed_version_check = false
          end
        end

        registered[name.to_sym] = if !passed_version_check
          "== #{name} failed version check. Requested #{version}, got #{Middleman::Core::VERSION}"
        elsif block_given?
          block
        elsif namespace
          namespace
        end
      end

      def load(name)
        name = name.to_sym
        return nil unless registered.has_key?(name)

        extension = registered[name]
        if extension.is_a?(Proc)
          extension = extension.call() || nil
          registered[name] = extension
        end

        extension
      end
    end
  end
  
  # Where to look in gems for extensions to auto-register
  EXTENSION_FILE = File.join("lib", "middleman_extension.rb")
  
  class << self
    
    # Recursively convert a normal Hash into a HashWithIndifferentAccess
    #
    # @private
    # @param [Hash] data Normal hash
    # @return [Thor::CoreExt::HashWithIndifferentAccess]
    def recursively_enhance(data)
      if data.is_a? Hash
        data = ::Thor::CoreExt::HashWithIndifferentAccess.new(data)
        data.each do |key, val|
          data[key] = recursively_enhance(val)
        end
        data
      elsif data.is_a? Array
        data.each_with_index do |val, i|
          data[i] = recursively_enhance(val)
        end
        data
      else
        data
      end
    end
    
    # Automatically load extensions from available RubyGems
    # which contain the EXTENSION_FILE
    #
    # @private
    def load_extensions_in_path
      extensions = rubygems_latest_specs.select do |spec|
        spec_has_file?(spec, EXTENSION_FILE)
      end
    
      extensions.each do |spec|
        require spec.name
      end
    end
  
    # Backwards compatible means of finding all the latest gemspecs
    # available on the system
    #
    # @private
    # @return [Array] Array of latest Gem::Specification
    def rubygems_latest_specs
      # If newer Rubygems
      if ::Gem::Specification.respond_to? :latest_specs
        ::Gem::Specification.latest_specs
      else
        ::Gem.source_index.latest_specs
      end
    end
  
    # Where a given Gem::Specification has a specific file. Used
    # to discover extensions and Sprockets-supporting gems.
    #
    # @private
    # @param [Gem::Specification]
    # @param [String] Path to look for
    # @return [Boolean] Whether the file exists
    def spec_has_file?(spec, path)
      full_path = File.join(spec.full_gem_path, path)
      File.exists?(full_path)
    end
  
    # Create a new Class which is based on Middleman::Base
    # Used to create a safe sandbox into which extensions and 
    # configuration can be included later without impacting
    # other classes and instances.
    #
    # @return [Class]
    def server(&block)
      Class.new(Middleman::Base)
    end
  
    # Creates a new Rack::Server
    #
    # @param [Hash] options to pass to Rack::Server.new
    # @return [Rack::Server]
    def start_server(options={})
      opts = {
        :Port      => options[:port] || 4567,
        :Host      => options[:host] || "0.0.0.0",
        :AccessLog => []
      }
    
      app_class = options[:app] ||= ::Middleman.server.inst
      opts[:app] = app_class
    
      # Disable for Beta 1. See if people notice.
      # require "thin"
      # ::Thin::Logging.silent = !options[:logging]
      # opts[:server] = 'thin'
      
      server = ::Rack::Server.new(opts)
      server.start
      server
    end
  end
end