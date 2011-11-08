require 'find'

module Middleman::CoreExtensions::Sitemap
  class << self
    def registered(app)
      app.set :sitemap, SitemapStore.new(app)
    end
    alias :included :registered
  end
  
  class SitemapStore
    def initialize(app)
      @app = app
      @map = {}
      @ignored_paths = false
      @generic_paths = false
      @proxied_paths = false
      
      @source = File.expand_path(@app.views, @app.root)
    
      build_static_map
    
      @app.on_file_change do |file|
        touch_file(file)
      end
    
      @app.on_file_delete do |file|
        remove_file(file)
      end
    end
    
    # Check to see if we know about a specific path
    def path_exists?(path)
      path = path.sub(/^\//, "")
      @map.has_key?(path)
    end
    
    def path_is_proxy?(path)
      path = path.sub(/^\//, "")
      return false if !path_exists?(path)
      @map[path].is_a?(String)
    end
    
    def path_target(path)
      path = path.sub(/^\//, "")
      @map[path]
    end
    
    def set_path(path, target=true)
      path   = path.sub(/^\//, "")
      target = target.sub(/^\//, "") if target.is_a?(String)
      
      @map[path] = target
      
      @ignored_paths = false if target === false
      @generic_paths = false if target === true
      @proxied_paths = false if target.is_a?(String)
    end
    
    def ignore_path(path)
      set_path(path, false)
    end
    
    def each(&block)
      @map.each do |k, v|
        yield(k, v)
      end
    end
    
    def all_paths
      @map.keys
    end
    
    def ignored_path?(path)
      path = path.sub(/^\//, "")
      ignored_paths.include?(path)
    end
    
    def ignored_paths
      @ignored_paths ||= begin
        ignored = []
        each do |k, v|
          ignored << k if v === false
        end
        ignored
      end
    end
    
    def generic_path?(path)
      path = path.sub(/^\//, "")
      generic_paths.include?(path)
    end
    
    def generic_paths
      @generic_paths ||= begin
        generic = []
        each do |k, v|
          generic << k if v === true
        end
        generic
      end
    end
    
    def proxied_path?(path)
      path = path.sub(/^\//, "")
      proxied_paths.include?(path)
    end
    
    def proxied_paths
      @proxied_paths ||= begin
        proxied = []
        each do |k, v|
          proxied << k if v.is_a?(String)
        end
        proxied
      end
    end
    
    def touch_file(file)
      touch_path(file_to_path(file))
    end
    
    def touch_path(path)
      set_path(path) unless path_exists?(path)
    end
    
    def remove_file(file)
      remove_path(file_to_path(file))
    end
    
    def remove_path(path)
      path = path.sub(/^\//, "")
      @map.delete(path) if path_exists?(path)
    end
    
  protected
    def build_static_map
      Find.find(@source) do |file|
        add_file(file)
      end
    end
    
    def file_to_path(file)
      path = file.sub(@source + "/", "")
      
      end_of_the_line = false
      while !end_of_the_line
        file_extension = File.extname(path)
      
        # TODO: Loop and continue popping Tilt-aware extensions
        if ::Tilt.mappings.has_key?(file_extension.gsub(/^\./, ""))
          path = path.sub(file_extension, "")
        else
          end_of_the_line = true
        end
      end
      
      path
    end
    
    def add_file(file)
      return false if file == @source ||
                      file.match(/\/\./) ||
                      (file.match(/\/_/) && !file.match(/\/__/)) ||
                      File.directory?(file)
    
      add_path(file_to_path(file))
    end
    
    def add_path(path)
      return false if path == "layout" ||
                      path.match(/^layouts/)
    
      set_path(path)
      
      true
    end
  end
end