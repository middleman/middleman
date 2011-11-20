require 'find'

module Middleman::CoreExtensions::Sitemap
  class << self
    def registered(app)
      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  module InstanceMethods
    def initialize
      file_changed do |file|
        sitemap.touch_file(file)
      end
    
      file_deleted do |file|
        sitemap.remove_file(file)
      end
      
      super
    end
    
    def sitemap
      @sitemap ||= SitemapStore.new(self)
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
  end
  
  class SitemapTemplate
    attr_accessor :page, :options, :locals, :blocks#, :dependencies
  
    def initialize(page)
      @page    = page
      @options = {}
      @locals  = {}
      @blocks  = []
    end
  #     
  #     def path
  #       @page.path
  #     end
  #     
  #     def store
  #       @page.store
  #     end
  #     
  #     def app
  #       store.app
  #     end
  #     
  #     def ext
  #       @page.ext
  #     end
  #     
  #     def metadata
  #       cache.fetch(:metadata, path) do
  #         metadata = {}
  #         provides_metadata.each do |callback, matcher|
  #           next if !matcher.nil? && !path.match(matcher)
  #           metadata.merge(instance_exec(path, &callback))
  #         end
  #         metadata
  #       end
  #     end
  #     
  #     def render(opts={}, locs={})
  #       opts = options.merge(metadata[:options]).merge(opts)
  #       locs = locals.merge(metadata[:locals]).merge(locs)
  #       
  #       blocks.each do |block|
  #         instance_eval(&block)
  #       end
  #      
  #       content = app.internal_render(path, locals, options)
  #       
  #       if layout_path
  #         content = app.internal_render(layout_path, locals, options) { content }
  #       end
  #       
  #       content
  #     end
  #   
  #   protected
  #     def self.cache
  #       @_cache ||= ::Middleman::Cache.new
  #     end
  #     
  #     def cache
  #       self.class.cache
  #     end
  # 
  #     def options_for_ext(ext)
  #       cache.fetch(:options_for_ext, ext) do
  #         options = {}
  # 
  #         extension_class = Tilt[ext]
  #         Tilt.mappings.each do |ext, engines|
  #           next unless engines.include? extension_class
  #           engine_options = respond_to?(ext.to_sym) ? send(ext.to_sym) : {}
  #           options.merge!(engine_options)
  #         end
  # 
  #         options
  #       end
  #     end
  #     
  #     def layout_path
  #       return false if %w(.js .css .txt).include?(ext)
  #       local_layout = options.has_key?(:layout) ? options[:layout] : app.layout
  #       return false unless local_layout
  #       
  #       engine_options = app.respond_to?(engine.to_sym) ? app.send(engine.to_sym) : {}
  # 
  #       layout_engine = if options.has_key?(:layout_engine)
  #         options[:layout_engine]
  #       elsif engine_options.has_key?(:layout_engine)
  #         engine_options[:layout_engine]
  #       else
  #         engine
  #       end
  # 
  #       layout_path, *etc = app.resolve_template(local_layout, :preferred_engine => layout_engine)
  # 
  #       if !layout_path
  #         local_layout = File.join("layouts", local_layout.to_s)
  #         layout_path, *etc = app.resolve_template(local_layout, :preferred_engine => layout_engine)
  #       end
  # 
  #       throw "Could not locate layout: #{local_layout}" unless layout_path
  #       layout_path
    end
    
    class SitemapPage
      attr_accessor :path, :source_file, :proxied_to, :status
      
      def initialize(store, path)
        @store       = store
        @path        = path
        @status      = :generic
        @source_file = nil
        @proxied_to  = nil
      end
      
      def template?
        return false if source_file.nil?
        !Tilt[source_file].nil?
      end
      
      def template
        @_template ||= SitemapTemplate.new(self)
      end
      
      def ext
        File.extname(path)
      end
      
      def mime_type
        @store.app.mime_type ext
      end
      
      def proxy?
        @status == :proxy
      end
      
      def proxy_to(target)
        @status = :proxy
        @proxied_to = target
      end
      
      def generic?
        @status == :generic
      end
      
      def make_generic
        @status = :generic
      end
      
      def ignored?
        @status == :ignored
      end
      
      def ignore
        @status = :ignored
      end
      
      def touch
      end
      
    protected
      def app
        @store.app
      end
    end
  
  class SitemapStore
    attr_accessor :app
    
    def initialize(app)
      @app = app
      @cache = ::Middleman::Cache.new
      @source = File.expand_path(@app.views, @app.root)
      @pages = {}
    end
    
    # Check to see if we know about a specific path
    def exists?(path)
      @pages.has_key?(path.sub(/^\//, ""))
    end
    
    def set_context(path, opts={}, blk=nil)
      page(path) do
        template.options = opts
        template.blocks  = [blk]
      end
    end
    
    def ignore(path)
      page(path) { ignore }
      @cache.remove(:ignored_paths)
    end
    
    def proxy(path, target)
      page(path) { proxy_to(target.sub(%r{^/}, "")) }
      @cache.remove(:proxied_paths)
    end
    
    def page(path, &block)
      path = path.sub(/^\//, "").gsub("%20", " ")
      @pages[path] = SitemapPage.new(self, path) unless @pages.has_key?(path)
      @pages[path].instance_exec(&block) if block_given?
      @pages[path]
    end
    
    def all_paths
      @pages.keys
    end
    
    def ignored?(path)
      ignored_paths.include?(path.sub(/^\//, ""))
    end
    
    def ignored_paths
      @cache.fetch :ignored_paths do
        @pages.values.select(&:ignored?).map(&:path)
      end
    end
    
    def generic?(path)
      generic_paths.include?(path.sub(/^\//, ""))
    end
    
    def generic_paths
      @cache.fetch :generic_paths do
        @pages.values.select(&:generic?).map(&:path)
      end
    end
    
    def proxied?(path)
      proxied_paths.include?(path.sub(/^\//, ""))
    end
    
    def proxied_paths
      @cache.fetch :proxied_paths do
        @pages.values.select(&:proxy?).map(&:path)
      end
    end
    
    def remove_file(file)
      path = file_to_path(file)
      return false unless path
      
      path = path.sub(/^\//, "")
      @pages.delete(path) if @pages.has_key?(path)
      @context_map.delete(path) if @context_map.has_key?(path)
    end
    
    def file_to_path(file)
      file = File.expand_path(file, @app.root)
      
      prefix = @source + "/"
      return false unless file.include?(prefix)
      
      path = file.sub(prefix, "")
      path = @app.extensionless_path(path)
      
      path
    end
    
    def touch_file(file)
      return false if file == @source ||
                      file.match(/^\./) ||
                      file.match(/\/\./) ||
                      (file.match(/\/_/) && !file.match(/\/__/)) ||
                      File.directory?(file)
                     
      path = file_to_path(file)
      
      return false unless path
      
      return false if path.match(%r{^layout}) ||
                      path.match(%r{^layouts/})
    
      # @app.logger.debug :sitemap_update, Time.now, path if @app.logging?
      
      # Add generic path
      page(path).source_file = File.expand_path(file, @app.root)
      
      true
    end
  end
end