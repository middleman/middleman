require "active_support/core_ext/hash/deep_merge"
require 'find'

module Middleman::CoreExtensions::Sitemap
  class << self
    def registered(app)
      app.set :ignored_sitemap_matchers, {
        # dotfiles and folders in the root
        :root_dotfiles => proc { |file, path| file.match(/^\./) },
        
        # Files starting with an dot, but not .htaccess
        :source_dotfiles => proc { |file, path| 
          (file.match(/\/\./) && !file.match(/\/\.htaccess/)) 
        },
        
        # Files starting with an underscore, but not a double-underscore
        :partials => proc { |file, path| (file.match(/\/_/) && !file.match(/\/__/)) },
        
        # Files without any output extension (layouts, partials)
        :extensionless => proc { |file, path| !path.match(/\./) },
      }
      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  module InstanceMethods
    def initialize
      super

      static_path = source_dir.sub(self.root, "").sub(/^\//, "")
      sitemap_regex = static_path.empty? ? // : (%r{^#{static_path + "/"}})
      
      file_changed sitemap_regex do |file|
        sitemap.touch_file(file)
      end

      file_deleted sitemap_regex do |file|
        sitemap.remove_file(file)
      end
    end
    
    def sitemap
      @sitemap ||= ::Middleman::Sitemap::Store.new(self)
    end
    
    def current_page
      sitemap.page(current_path)
    end
    
    # Keep a path from building
    def ignore(path)
      sitemap.ignore(path)
    end
    
    def reroute(url, target)
      sitemap.proxy(url, target)
    end
    
    def provides_metadata(matcher=nil, &block)
      @_provides_metadata ||= []
      @_provides_metadata << [block, matcher] if block_given?
      @_provides_metadata
    end
    
    def provides_metadata_for_path(matcher=nil, &block)
      @_provides_metadata_for_path ||= []
      @_provides_metadata_for_path << [block, matcher] if block_given?
      @_provides_metadata_for_path
    end
  end
end