# Used for merging results of metadata callbacks
require "active_support/core_ext/hash/deep_merge"

# Sitemap namespace
module Middleman::Sitemap

  # Template class
  class Template
    
    # @return [Middleman::Sitemap::Page]
    attr_accessor :page
    
    # @return [Hash]
    attr_accessor :options
    
    # @return [Hash]
    attr_accessor :locals
    
    # @return [String]
    attr_accessor :request_path
  
    # Initialize template with parent page
    # @param [Middleman::Sitemap:Page] page
    def initialize(page)
      @page    = page
      @options = {}
      @locals  = {}
      @blocks  = []
    end
  
    # Simple aliases
    delegate :path, :source_file, :store, :app, :ext, :to => :page
    
    # Clear internal frontmatter cache for file if it changes
    # @return [void]
    def touch
      app.cache.remove(:metadata, source_file)
    end
    
    # Clear internal frontmatter cache for file if it is deleted
    # @return [void]
    def delete
      app.cache.remove(:metadata, source_file)
    end
    
    # Get the metadata for both the current source_file and the current path
    # @return [Hash]
    def metadata
      metadata = app.cache.fetch(:metadata, source_file) do
        data = { :options => {}, :locals => {}, :page => {}, :blocks => [] }
        
        app.provides_metadata.each do |callback, matcher|
          next if !matcher.nil? && !source_file.match(matcher)
          result = app.instance_exec(source_file, &callback)
          data = data.deep_merge(result)
        end
        
        data
      end
      
      app.provides_metadata_for_path.each do |callback, matcher|
        if matcher.is_a? Regexp
          next if !self.request_path.match(matcher)
        elsif matcher.is_a? String
          next if !File.fnmatch("/" + matcher.sub(%r{^/}, ''), "/#{self.request_path}")
        end
      
        result = app.instance_exec(self.request_path, &callback)
        if result.has_key?(:blocks)
          metadata[:blocks] << result[:blocks]
          result.delete(:blocks)
        end
        
        metadata = metadata.deep_merge(result)
      end
      
      metadata
    end

    # Render this template
    # @param [Hash] opts
    # @param [Hash] locs
    # @return [String]
    def render(opts={}, locs={}, &block)
      puts "== Render Start: #{source_file}" if app.logging?
      
      md   = metadata.dup
      opts = options.deep_merge(md[:options]).deep_merge(opts)
      locs = locals.deep_merge(md[:locals]).deep_merge(locs)
      
      # Forward remaining data to helpers
      if md.has_key?(:page)
        app.data.store("page", md[:page])
      end
      
      md[:blocks].flatten.compact.each do |block|
        app.instance_eval(&block)
      end
      
      app.instance_eval(&block) if block_given?
      result = app.render_template(source_file, locs, opts)
      
      puts "== Render End: #{source_file}" if app.logging?
      result
    end
  end
end