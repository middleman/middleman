require 'active_support/core_ext/hash/keys'
require 'pathname'

# Parsing YAML frontmatter
require 'yaml'

# Parsing JSON frontmatter
require 'active_support/json'

# Extensions namespace
module Middleman::CoreExtensions
  class FrontMatter < ::Middleman::Extension
    YAML_ERRORS = [StandardError]

    # https://github.com/tenderlove/psych/issues/23
    if defined?(Psych) && defined?(Psych::SyntaxError)
      YAML_ERRORS << Psych::SyntaxError
    end

    def initialize(app, options_hash={}, &block)
      super

      @cache = {}
    end

    def before_configuration
      ext = self
      app.files.changed { |file| ext.clear_data(file) }
      app.files.deleted { |file| ext.clear_data(file) }
    end

    def after_configuration
      app.sitemap.provides_metadata do |path|
        frontmatter = data(path).first
        self.class.frontmatter_to_metadata(frontmatter)
      end
    end

    def self.frontmatter_to_metadata(frontmatter)
      options = {}

      [:layout, :layout_engine].each do |opt|
        options[opt] = frontmatter[opt] unless frontmatter[opt].nil?
      end

      if frontmatter[:renderer_options]
        options[:renderer_options] = {}
        frontmatter[:renderer_options].each do |k, v|
          options[:renderer_options][k.to_sym] = v
        end
      end

      { options: options, data: frontmatter }
    end

    # Get the template data from a path
    # @param [String] path
    # @return [String]
    def template_data_for_file(path)
      data(path).last
    end

    def data(path)
      p = normalize_path(path)
      @cache[p] ||= self.class.frontmatter_and_content(app, p)
    end

    def clear_data(file)
      # Copied from Sitemap::Store#file_to_path, but without
      # removing the file extension
      file = File.join(app.root, file)
      prefix = app.source_dir.sub(/\/$/, '') + '/'
      return unless file.include?(prefix)
      path = file.sub(prefix, '')

      @cache.delete(path)
    end

    # Parse YAML frontmatter out of a string
    # @param [String] content
    # @return [Array<Hash, String>]
    def self.parse_yaml_front_matter(app, content, full_path)
      yaml_regex = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
      if content =~ yaml_regex
        content = content.sub(yaml_regex, '')

        begin
          data = YAML.load($1) || {}
          data = data.symbolize_keys
        rescue *YAML_ERRORS => e
          app.logger.error "YAML Exception parsing #{full_path}: #{e.message}"
          return false
        end
      else
        return false
      end

      [data, content]
    rescue
      [{}, content]
    end

    def self.parse_json_front_matter(app, content, full_path)
      json_regex = /\A(;;;\s*\n.*?\n?)^(;;;\s*$\n?)/m

      if content =~ json_regex
        content = content.sub(json_regex, '')

        begin
          json = ($1 + $2).sub(';;;', '{').sub(';;;', '}')
          data = ActiveSupport::JSON.decode(json).symbolize_keys
        rescue => e
          app.logger.error "JSON Exception parsing #{full_path}: #{e.message}"
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
    # @return [Array<Middleman::Util::HashWithIndifferentAccess, String>]
    def self.frontmatter_and_content(app, path)
      full_path = if Pathname(path).relative?
        File.join(app.source_dir, path)
      else
        path
      end

      data = {}

      return [data, nil] if !app.files.exists?(full_path) || ::Middleman::Util.binary?(full_path)

      content = File.read(full_path)

      begin
        if content =~ /\A.*coding:/
          lines = content.split(/\n/)
          lines.shift
          content = lines.join("\n")
        end

        result = parse_yaml_front_matter(app, content, full_path) || parse_json_front_matter(app, content, full_path)
        return result if result
      rescue
        # Probably a binary file, move on
      end

      [data, content]
    end

    def normalize_path(path)
      path.sub(%r{^#{Regexp.escape(app.source_dir)}\/}, '')
    end
  end
end
