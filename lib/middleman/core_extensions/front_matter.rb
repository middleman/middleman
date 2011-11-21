require "yaml"
require "tilt"

module Middleman::CoreExtensions::FrontMatter
  class << self
    def registered(app)
      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  module InstanceMethods
    def initialize
      file_changed FrontMatter.matcher do |file|
        frontmatter.touch_file(file)
      end
      
      file_deleted do |file|
        frontmatter.remove_file(file)
      end
      
      provides_metadata FrontMatter.matcher do |path|
        relative_path = path.sub(source_dir, "")
        
        data = if frontmatter.has_data?(relative_path)
          frontmatter.data(relative_path).first
        else
          {}
        end
        
        # Forward remaining data to helpers
        data_content("page", data)
        
        %w(layout layout_engine).each do |opt|
          if data.has_key?(opt)
            data[opt.to_sym] = data.delete(opt)
          end
        end
        
        { :options => data }
      end
        
      super
    end
    
    def frontmatter
      @frontmatter ||= FrontMatter.new(self)
    end
  end
  
  class FrontMatter
    class << self
      def matcher
        %r{source/.*\.html}
      end
    end
    
    def initialize(app)
      @app = app
      @source = File.expand_path(@app.views, @app.root)
      @local_data = {}
    end
    
    def has_data?(path)
      @local_data.has_key?(path.to_s)
    end
    
    def touch_file(file)
      extension = File.extname(file).sub(/\./, "")
      return unless ::Tilt.mappings.has_key?(extension)
      
      file = File.expand_path(file, @app.root)
      content = File.read(file)
      
      # @app.logger.debug :frontmatter_update, Time.now, file if @app.logging?
      result = parse_front_matter(content)
        
      if result
        file = file.sub(@app.source_dir, "")
        @local_data[file] = result
        path = File.join(@app.source_dir, file)
        @app.cache.set([:raw_template, path], result[1])
      end
    end
    
    def remove_file(file)
      file = File.expand_path(file, @app.root)
      file = file.sub(@app.source_dir, "")
      # @app.logger.debug :frontmatter_remove, Time.now, file if @app.logging?
      
      if @local_data.has_key?(file)
        @local_data.delete(file) 
      end
    end
    
    def data(path)
      if @local_data.has_key?(path.to_s)
        @local_data[path.to_s]
      else
        nil
      end
    end
    
  private
    def parse_front_matter(content)
      yaml_regex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      if content =~ yaml_regex
        begin
          data = YAML.load($1)
        rescue => e
          puts "YAML Exception: #{e.message}"
          return false
        end

        content = content.split(yaml_regex).last
      else
        return false
      end

      [data, content]
    end
  end
end