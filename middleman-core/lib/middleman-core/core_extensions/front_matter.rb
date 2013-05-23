require "active_support/core_ext/hash/keys"
require 'pathname'

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

        app.send :include, InstanceMethods

        app.before_configuration do
          files.changed { |file| frontmatter_manager.clear_data(file) }
          files.deleted { |file| frontmatter_manager.clear_data(file) }
        end

        app.after_configuration do
          ::Middleman::Sitemap::Resource.send :include, ResourceInstanceMethods

          ignore %r{\.frontmatter$}

          sitemap.provides_metadata do |path|
            fmdata = frontmatter_manager.data(path).first || {}

            data = {}
            [:layout, :layout_engine].each do |opt|
              data[opt] = fmdata[opt] unless fmdata[opt].nil?
            end

            { :options => data, :page => ::Middleman::Util.recursively_enhance(fmdata).freeze }
          end
        end
      end
      alias :included :registered
    end

    class FrontmatterManager
      attr_reader :app
      delegate :logger, :to => :app

      def initialize(app)
        @app = app
        @cache = {}
      end

      def data(path)
        p = normalize_path(path)
        @cache[p] ||= begin
          file_data, content = frontmatter_and_content(p)

          if @app.files.exists?("#{path}.frontmatter")
            external_data, _ = frontmatter_and_content("#{p}.frontmatter")

            [
              external_data.deep_merge(file_data),
              content
            ]
          else
            [file_data, content]
          end
        end
      end

      def clear_data(file)
        # Copied from Sitemap::Store#file_to_path, but without
        # removing the file extension
        file = File.join(@app.root, file)
        prefix = @app.source_dir.sub(/\/$/, "") + "/"
        return unless file.include?(prefix)
        path = file.sub(prefix, "").sub(/\.frontmatter$/, "")

        @cache.delete(path)
      end

      YAML_ERRORS = [ StandardError ]

      # https://github.com/tenderlove/psych/issues/23
      if defined?(Psych) && defined?(Psych::SyntaxError)
        YAML_ERRORS << Psych::SyntaxError
      end

      # Parse YAML frontmatter out of a string
      # @param [String] content
      # @return [Array<Hash, String>]
      def parse_yaml_front_matter(content)
        yaml_regex = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
        if content =~ yaml_regex
          content = content.sub(yaml_regex, "")

          begin
            data = YAML.load($1) || {}
            data = data.symbolize_keys
          rescue *YAML_ERRORS => e
            logger.error "YAML Exception: #{e.message}"
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
        json_regex = /\A(;;;\s*\n.*?\n?)^(;;;\s*$\n?)/m

        if content =~ json_regex
          content = content.sub(json_regex, "")

          begin
            json = ($1+$2).sub(";;;", "{").sub(";;;", "}")
            data = ActiveSupport::JSON.decode(json).symbolize_keys
          rescue => e
            logger.error "JSON Exception: #{e.message}"
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
        full_path = if Pathname(path).relative?
          File.join(@app.source_dir, path)
        else
          path
        end

        data = {}
        content = nil

        return [data, content] unless @app.files.exists?(full_path)

        if !::Middleman::Util.binary?(full_path)
          content = File.read(full_path)
          
          begin
            if content =~ /\A.*coding:/
              lines = content.split(/\n/)
              lines.shift
              content = lines.join("\n")
            end

            if result = parse_yaml_front_matter(content)
              data, content = result
            elsif result = parse_json_front_matter(content)
              data, content = result
            end
          rescue
            # Probably a binary file, move on
          end
        end

        [data, content]
      end

      def normalize_path(path)
        path.sub(%r{^#{@app.source_dir}\/}, "")
      end
    end

    module ResourceInstanceMethods

      def ignored?
        if !proxy? && data["ignored"] == true
          true
        else
          super
        end
      end

      # This page's frontmatter without being enhanced for access by either symbols or strings.
      # Used internally
      # @private
      # @return [Hash]
      def raw_data
        app.frontmatter_manager.data(source_file).first
      end

      # This page's frontmatter
      # @return [Hash]
      def data
        ::Middleman::Util.recursively_enhance(raw_data).freeze
      end

      # Override Resource#content_type to take into account frontmatter
      def content_type
        # Allow setting content type in frontmatter too
        fm_type = data[:content_type]
        return fm_type if fm_type

        super
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
