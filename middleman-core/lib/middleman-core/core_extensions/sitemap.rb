# Used for merging results of metadata callbacks
require "active_support/core_ext/hash/deep_merge"

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
    # @return [Middleman::Sitemap::Base]
    def sitemap
      @_sitemap ||= ::Middleman::Sitemap::Base.new(self)
    end
    
    # Get the page object for the current path
    # @return [Middleman::Sitemap::Page]
    def current_page
      sitemap[current_path]
    end

    # Register a handler to provide metadata on a file path
    # @param [Regexp] matcher
    # @return [Array<Array<Proc, Regexp>>]
    def provides_metadata(matcher=nil, &block)
      @_provides_metadata ||= []
      @_provides_metadata << [block, matcher] if block_given?
      @_provides_metadata
    end
    
    def metadata_for_file(source_file)
      metadata = { :options => {}, :locals => {}, :page => {}, :blocks => [] }

      provides_metadata.each do |callback, matcher|
        next if !matcher.nil? && !source_file.match(matcher)
        result = instance_exec(source_file, &callback)
        metadata = metadata.deep_merge(result)
      end

      metadata
    end
    
    # Register a handler to provide metadata on a url path
    # @param [Regexp] matcher
    # @return [Array<Array<Proc, Regexp>>]
    def provides_metadata_for_path(matcher=nil, &block)
      @_provides_metadata_for_path ||= []
      @_provides_metadata_for_path << [block, matcher] if block_given?
      @_provides_metadata_for_path
    end
    
    def metadata_for_path(request_path)
      metadata = { :options => {}, :locals => {}, :page => {}, :blocks => [] }
      
      provides_metadata_for_path.each do |callback, matcher|
        if matcher.is_a? Regexp
          next if !request_path.match(matcher)
        elsif matcher.is_a? String
          next if !File.fnmatch("/" + matcher.sub(%r{^/}, ''), "/#{request_path}")
        end

        result = instance_exec(request_path, &callback)
        if result.has_key?(:blocks)
          metadata[:blocks] << result[:blocks]
          result.delete(:blocks)
        end

        metadata = metadata.deep_merge(result)
      end

      metadata
    end
  end
end