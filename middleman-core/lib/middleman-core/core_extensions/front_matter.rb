# Parsing YAML frontmatter
require "yaml"

# Looking up Tilt extensions
require "tilt"

# Frontmatter namespace
module Middleman::CoreExtensions::FrontMatter
  
  # Setup extension
  class << self
    
    # Once registered
    def registered(app)
      app.set :frontmatter_extensions, %w(.htm .html .php)
      app.extend ClassMethods
      app.send :include, InstanceMethods
      app.delegate :frontmatter_changed, :to => :"self.class"
    end
    alias :included :registered
  end
  
  # Frontmatter class methods
  module ClassMethods
    
    # Register callback on frontmatter updates
    # @param [Regexp] matcher
    # @return [Array<Array<Proc, Regexp>>]
    def frontmatter_changed(matcher=nil, &block)
      @_frontmatter_changed ||= []
      @_frontmatter_changed << [block, matcher] if block_given?
      @_frontmatter_changed
    end
  end
  
  # Frontmatter instance methods
  module InstanceMethods
    
    # Override init
    def initialize
      super
      
      exts = frontmatter_extensions.join("|").gsub(".", "\.")
      
      static_path = source_dir.sub(root, "").sub(/^\//, "").sub(/\/$/, "") + "/"

      matcher = %r{#{static_path}.*(#{exts})}
      
      files.changed matcher do |file|
        frontmatter_extension.touch_file(file)
      end

      files.deleted matcher do |file|
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

    # Notify callbacks that the frontmatter changed
    # @param [String] path
    # @return [void]
    def frontmatter_did_change(path)
      frontmatter_changed.each do |callback, matcher|
        next if path.match(%r{^#{build_dir}/})
        next if !matcher.nil? && !path.match(matcher)
        instance_exec(path, &callback)
      end
    end
    
    # Get the frontmatter object
    # @return [Middleman::CoreExtensions::FrontMatter::FrontMatter]
    def frontmatter_extension
      @_frontmatter_extension ||= FrontMatter.new(self)
    end
    
    # Get the frontmatter for the given params
    # @param [String] path
    # @return [Hash, nil]
    def frontmatter(*args)
      frontmatter_extension.data(*args)
    end
  end
  
  # Core Frontmatter class
  class FrontMatter
    
    # Initialize frontmatter with current app
    # @param [Middleman::Base] app
    def initialize(app)
      @app = app
      @source = File.expand_path(@app.source, @app.root)
      @local_data = {}
      
      # Setup ignore callback
      @app.ignore do |path|
        p = @app.sitemap.page(path)
        file_path = p.source_file.sub(@app.source_dir, "")
        
        if !p.proxy? && has_data?(file_path)
          d = data(file_path)
          if d && d[0]
            d[0].has_key?("ignored") && d[0]["ignored"] == true
          else
            false
          end
        else
          false
        end
      end
    end
    
    # Whether the frontmatter knows about a path
    # @param [String] path
    # @return [Boolean]
    def has_data?(path)
      @local_data.has_key?(path.to_s)
    end
    
    # Update frontmatter if a file changes
    # @param [String] file
    # @return [void]
    def touch_file(file)
      extension = File.extname(file).sub(/\./, "")
      return unless ::Tilt.mappings.has_key?(extension)
      
      file = File.expand_path(file, @app.root)
      content = File.read(file)
      
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
    
    # Update frontmatter if a file is delted
    # @param [String] file
    # @return [void]
    def remove_file(file)
      file = File.expand_path(file, @app.root)
      file = file.sub(@app.source_dir, "")
      
      if @local_data.has_key?(file)
        path = File.join(@app.source_dir, file)
        @app.cache.remove(:raw_template, path)
        @local_data.delete(file) 
      end
    end
    
    # Get the frontmatter for a given path
    # @param [String] path
    # @return [Hash, nil]
    def data(path)
      if @local_data.has_key?(path.to_s)
        @local_data[path.to_s]
      else
        nil
      end
    end
    
  private
    # Parse frontmatter out of a string
    # @param [String] content
    # @return [Array<Hash, String>]
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
