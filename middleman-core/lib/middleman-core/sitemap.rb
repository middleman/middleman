# Core Sitemap Extensions
module Middleman::Sitemap
  
  autoload :Store,        "middleman-core/sitemap/store"
  autoload :Resource,     "middleman-core/sitemap/resource"
  
  module Extensions
    autoload :OnDisk,     "middleman-core/sitemap/extensions/on_disk"
    autoload :Proxies,    "middleman-core/sitemap/extensions/proxies"
    autoload :Ignores,    "middleman-core/sitemap/extensions/ignores"
    autoload :Traversal,  "middleman-core/sitemap/extensions/traversal"
  end
  
  # Setup Extension
  class << self
    
    # Once registered
    def registered(app)
      
      app.register Middleman::Sitemap::Extensions::Proxies
      app.register Middleman::Sitemap::Extensions::Ignores
      
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
      
      # Initialize Sitemap
      app.before_configuration do
        sitemap
      end
    end
    alias :included :registered
  
  end
  
  # Sitemap instance methods
  module InstanceMethods
    
    # Get the sitemap class instance
    # @return [Middleman::Sitemap::Store]
    def sitemap
      @_sitemap ||= Store.new(self)
    end
    
    # Get the resource object for the current path
    # @return [Middleman::Sitemap::Resource]
    def current_page
      current_resource
    end
    
    # Get the resource object for the current path
    # @return [Middleman::Sitemap::Resource]
    def current_resource
      sitemap.find_resource_by_destination_path(current_path)
    end
    
  end
end