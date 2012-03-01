# Core Sitemap Extensions
module Middleman::CoreExtensions::Sitemap
  
  # Setup Extension
  class << self
    
    # Once registered
    def registered(app)
      # Setup callbacks which can exclude paths from the sitemap
      app.set :ignored_sitemap_matchers, {
        # dotfiles and folders in the root
        :root_dotfiles => proc { |file, path| file.match(/^\./) },
        
        # Files starting with an dot, but not .htaccess
        :source_dotfiles => proc { |file, path| 
          (file.match(/\/\./) && !file.match(/\/\.htaccess/)) 
        },
        
        # Files starting with an underscore, but not a double-underscore
        :partials => proc { |file, path| (file.match(/\/_/) && !file.match(/\/__/)) },
        
        :layout => proc { |file, path| 
          file.match(/^source\/layout\./) || file.match(/^source\/layouts\//)
        },
        
        # Files without any output extension (layouts, partials)
        # :extensionless => proc { |file, path| !path.match(/\./) },
      }
      
      # Include instance methods
      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  # Sitemap instance methods
  module InstanceMethods
    
    # Extend initialize to listen for change events
    def initialize
      super

      # Cleanup paths
      static_path = source_dir.sub(root, "").sub(/^\//, "")
      sitemap_regex = static_path.empty? ? // : (%r{^#{static_path + "/"}})
      
      # Register file change callback
      files.changed sitemap_regex do |file|
        sitemap.touch_file(file)
      end
      
      # Register file delete callback
      files.deleted sitemap_regex do |file|
        sitemap.remove_file(file)
      end
    end
    
    # Get the sitemap class instance
    # @return [Middleman::Sitemap::Store]
    def sitemap
      @_sitemap ||= ::Middleman::Sitemap::Store.new(self)
    end
    
    # Get the page object for the current path
    # @return [Middleman::Sitemap::Page]
    def current_page
      sitemap.page(current_path)
    end
    
    # Ignore a path, regex or callback
    # @param [String, Regexp]
    # @return [void]
    def ignore(*args, &block)
      sitemap.ignore(*args, &block)
    end
    
    # Proxy one path to another
    # @param [String] url
    # @param [String] target
    # @return [void]
    def proxy(*args)
      sitemap.proxy(*args)
    end

    # Register a handler to provide metadata on a file path
    # @param [Regexp] matcher
    # @return [Array<Array<Proc, Regexp>>]
    def provides_metadata(matcher=nil, &block)
      @_provides_metadata ||= []
      @_provides_metadata << [block, matcher] if block_given?
      @_provides_metadata
    end
    
    # Register a handler to provide metadata on a url path
    # @param [Regexp] matcher
    # @return [Array<Array<Proc, Regexp>>]
    def provides_metadata_for_path(matcher=nil, &block)
      @_provides_metadata_for_path ||= []
      @_provides_metadata_for_path << [block, matcher] if block_given?
      @_provides_metadata_for_path
    end
  end
end
