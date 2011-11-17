require "yaml"
require "tilt"

module Middleman::CoreExtensions::FrontMatter
  class << self
    def registered(app)
      app.extend ClassMethods
      app.send :include, InstanceMethods
      
      app.file_changed do |file|
        frontmatter.touch_file(file)
      end
      
      app.file_deleted do |file|
        frontmatter.remove_file(file)
      end
      
      app.after_configuration do
        app.before_processing(:front_matter) do |result|
          if result && Tilt.mappings.has_key?(result[1].to_s)
            extensionless_path, template_engine = result
            full_file_path = "#{extensionless_path}.#{template_engine}"

            if app.frontmatter.has_data?(full_file_path)
              data = app.frontmatter.data(full_file_path).first
              
              request['custom_options'] = {}
              %w(layout layout_engine).each do |opt|
                if data.has_key?(opt)
                  request['custom_options'][opt.to_sym] = data[opt]
                end
              end
            else
              data = {}
            end
            
            # Forward remaining data to helpers
            app.data_content("page", data)
          end
        
          true
        end
      end
    end
    alias :included :registered
  end
  
  module ClassMethods
    def frontmatter
      @frontmatter ||= FrontmatterData.new(self)
    end
  end
  
  module InstanceMethods
    def frontmatter
      settings.frontmatter
    end
  end
  
  class FrontmatterData
    def initialize(app)
      @app = app
      @source ||= File.expand_path(@app.views, @app.root)
      @local_data = {}
      
      views_dir = @app.views
      views_dir = File.join(@app.root, @app.views) unless views_dir.include?(@app.root)
      
      Dir[File.join(views_dir, "**/*")].each do |file|
        next if file.match(/\/\./) ||
                (file.match(/\/_/) && !file.match(/\/__/)) ||
                File.directory?(file)
        
        touch_file(file)
      end
    end
    
    def has_data?(path)
      @local_data.has_key?(path.to_s)
    end
    
    def touch_file(file)
      extension = File.extname(file).sub(/\./, "")
      return unless ::Tilt.mappings.has_key?(extension)
      
      content = File.read(file)
      file = file.sub(@source, "")
      
      @app.logger.debug :frontmatter_update, Time.now, file if @app.settings.logging?
      result = parse_front_matter(content)
        
      if result
        @local_data[file] = result
        path = @app.extensionless_path(file)
        @app.settings.templates[path.to_sym] = [result[1], path.to_s, 1]
      end
    end
    
    def remove_file(file)
      file = file.sub(@source, "")
      @app.logger.debug :frontmatter_remove, Time.now, file if @app.settings.logging?
      
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