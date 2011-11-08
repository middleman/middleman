require 'find'

module Middleman
  class Sitemap
    def self.singleton
      @@singleton || nil
    end
      
    def initialize(app)
      @app = app
      @map = {}
      @ignored_paths = nil
      @generic_paths = nil
      @proxied_paths = nil
      
      @source = File.expand_path(@app.views, @app.root)
      
      build_static_map

      each do |request, destination|
        $stderr.puts request
      end
      
      @@singleton = self
    end
    
    # Check to see if we know about a specific path
    def path_exists?(path)
      @map.has_key?(path)
    end
    
    def path_is_proxy?(path)
      return false if !path_exists?(path)
      @map[path].is_a?(String)
    end
    
    def path_target(path)
      @map[path]
    end
    
    def set_path(path, target=true)
      @map[path] = target
      
      @ignored_paths = nil if target.nil?
      @generic_paths = nil if target === true
      @proxied_paths = nil if target.is_a?(String)
    end
    
    def ignore_path(path)
      set_path(path, nil)
    end
    
    def each(&block)
      @map.each do |k, v|
        next if v.nil?
        
        yield(k, v)
      end
    end
    
    def ignored_paths
      @ignored_paths ||= begin
        ignored = []
        each do |k, v|
          ignored << k unless v.nil?
        end
        ignored
      end
    end
    
    def generic_paths
      @generic_paths ||= begin
        generic = []
        each do |k, v|
          generic << k unless v === true
        end
        generic
      end
    end
    
    def proxied_paths
      @proxied_paths ||= begin
        proxied = []
        each do |k, v|
          proxied << k unless target.is_a?(String)
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
      if @map.has_key?(path)
        @map.delete(path)
      end
    end
    
  protected

    def build_static_map
      # found_template = resolve_template(request_path, :raise_exceptions => false)
      
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

module Guard
  class MiddlemanSitemap < Guard
    def initialize(watchers = [], options = {})
      super
      @options = options
    end
  
    def run_on_change(files)
      files.each do |file|
        ::Middleman::Sitemap.singleton.touch_file(file)
      end
    end
    
    def run_on_deletion(files)
      files.each do |file|
        ::Middleman::Sitemap.singleton.remove_file(file)
      end
    end
  end
end

# Add Sitemap guard
Middleman::Guard.add_guard do
  %Q{
    guard 'middlemansitemap' do 
      watch(%r{^source/(.*)})
    end
  }
end