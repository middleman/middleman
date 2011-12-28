require "yaml"
require "tilt"

module Middleman::CoreExtensions::FrontMatter
  class << self
    def registered(app)
      app.set :frontmatter_extensions, %w(.htm .html .php)
      app.extend ClassMethods
      app.send :include, InstanceMethods
      app.delegate :frontmatter_changed, :to => :"self.class"
    end
    alias :included :registered
  end
  
  module ClassMethods
    def frontmatter_changed(matcher=nil, &block)
      @_frontmatter_changed ||= []
      @_frontmatter_changed << [block, matcher] if block_given?
      @_frontmatter_changed
    end
  end
  
  module InstanceMethods
    def initialize
      super
      
      exts = frontmatter_extensions.join("|").gsub(".", "\.")
      
      static_path = source_dir.sub(self.root, "").sub(/^\//, "").sub(/\/$/, "") + "/"

      matcher = %r{#{static_path}.*(#{exts})}
      
      file_changed matcher do |file|
        frontmatter_extension.touch_file(file)
      end

      file_deleted matcher do |file|
        frontmatter_extension.remove_file(file)
      end

      provides_metadata matcher do |path|
        relative_path = path.sub(source_dir, "")

        fmdata = if frontmatter_extension.has_data?(relative_path)
          frontmatter(relative_path)[0]
        else
          {}
        end

        data = {}
        %w(layout layout_engine).each do |opt|
          data[opt.to_sym] = fmdata[opt] if fmdata.has_key?(opt)
        end

        { :options => data, :page => fmdata }
      end
    end

    def frontmatter_did_change(path)
      frontmatter_changed.each do |callback, matcher|
        next if path.match(%r{^#{build_dir}/})
        next if !matcher.nil? && !path.match(matcher)
        instance_exec(path, &callback)
      end
    end
    
    def frontmatter_extension
      @_frontmatter_extension ||= FrontMatter.new(self)
    end
    
    def frontmatter(*args)
      frontmatter_extension.data(*args)
    end
  end
  
  class FrontMatter
    def initialize(app)
      @app = app
      @source = File.expand_path(@app.source, @app.root)
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
        data, content = result
        data = ::Middleman.recursively_enhance(data)
        file = file.sub(@app.source_dir, "")
        @local_data[file] = [data, content]
        path = File.join(@app.source_dir, file)
        @app.cache.set([:raw_template, path], result[1])
        @app.frontmatter_did_change(path)
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
