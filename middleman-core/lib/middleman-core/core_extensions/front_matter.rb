# Extensions namespace
module Middleman::CoreExtensions
  
  # Frontmatter namespace
  module FrontMatter
  
    # Setup extension
    class << self
    
      # Once registered
      def registered(app)
        # Parsing YAML frontmatter
        require "yaml"
        
        # Parsing JSON frontmatter
        require "active_support/json"
      
        app.after_configuration do
          ::Middleman::Sitemap::Resource.send :include, ResourceInstanceMethods
      
          app.send :include, InstanceMethods
        
          files.changed { |file| frontmatter_manager.clear_data(file) }
          files.deleted { |file| frontmatter_manager.clear_data(file) }
        
          sitemap.register_resource_list_manipulator(
            :frontmatter,
            frontmatter_manager
          )
          
          sitemap.provides_metadata do |path|
            fmdata = frontmatter_manager.data(path).first
        
            data = {}
            %w(layout layout_engine).each do |opt|
              data[opt.to_sym] = fmdata[opt] if fmdata[opt]
            end
          
            { :options => data, :page => fmdata }
          end
        end
      end
      alias :included :registered
    end
  
    class FrontmatterManager
      def initialize(app)
        @app = app
        @cache = {}
      end
      
      def data(path)
        p = normalize_path(path)
        @cache[p] ||= frontmatter_and_content(p)
      end
      
      def clear_data(path)
        p = normalize_path(File.expand_path(path, @app.root))
        @cache.delete(p)
      end
      
      # Parse YAML frontmatter out of a string
      # @param [String] content
      # @return [Array<Hash, String>]
      def parse_yaml_front_matter(content)
        yaml_regex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        if content =~ yaml_regex
          content = content.sub(yaml_regex, "")

          begin
            data = YAML.load($1)
          rescue => e
            puts "YAML Exception: #{e.message}"
            return false
          end

        else
          return false
        end

        [data, content]
      rescue
        [{}, content]
      end
      
      def parse_json_front_matter(content)
        json_regex = /^(\{\{\{\s*\n.*?\n?)^(\}\}\}\s*$\n?)/m
        
        if content =~ json_regex
          content = content.sub(json_regex, "")

          begin
            json = ($1+$2).sub("{{{", "{").sub("}}}", "}")
            data = ActiveSupport::JSON.decode(json)
          rescue => e
            puts "JSON Exception: #{e.message}"
            return false
          end

        else
          return false
        end

        [data, content]
      rescue
        [{}, content]
      end
      
      # Get the frontmatter and plain content from a file
      # @param [String] path
      # @return [Array<Thor::CoreExt::HashWithIndifferentAccess, String>]
      def frontmatter_and_content(path)
        full_path = File.expand_path(path, @app.source_dir)
        content = File.read(full_path)

        if result = parse_yaml_front_matter(content)
          data, content = result
          data = ::Middleman::Util.recursively_enhance(data).freeze
        elsif result = parse_json_front_matter(content)
          data, content = result
          data = ::Middleman::Util.recursively_enhance(data).freeze
        else
          data = {}
        end

        [data, content]
      end
      
      def normalize_path(path)
        path.sub(@app.source_dir, "").sub(/^\//, "")
      end
      
      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        resources.each do |r|
          if !r.proxy? && r.data["ignored"] == true
            r.frontmatter_ignored = true
          end
        end
        
        resources
      end
    end
  
    module ResourceInstanceMethods
      
      def frontmatter_ignored?
        @_frontmatter_ignored || false
      end
      
      def frontmatter_ignored=(v)
        @_frontmatter_ignored = v
      end
      
      def ignored?
        if frontmatter_ignored?
          true
        else
          super
        end
      end

      # This page's frontmatter
      # @return [Hash]
      def data
        app.frontmatter_manager.data(source_file).first
      end

    end
    
    module InstanceMethods
    
      # Access the Frontmatter API
      def frontmatter_manager
        @_frontmatter_manager ||= FrontmatterManager.new(self)
      end
    
      # Get the template data from a path
      # @param [String] path
      # @return [String]
      def template_data_for_file(path)
        frontmatter_manager.data(path).last
      end
    
    end
  end
end