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
      app.extensions[:frontmatter] = self
      app.ignore %r{\.frontmatter$}

      ::Middleman::Sitemap::Resource.send :include, ResourceInstanceMethods

      app.sitemap.provides_metadata do |path|
        fmdata = data(path).first

        data = {}
        [:layout, :layout_engine].each do |opt|
          data[opt] = fmdata[opt] unless fmdata[opt].nil?
        end

        { options: data, page: ::Middleman::Util.recursively_enhance(fmdata).freeze }
      end
    end

    module ResourceInstanceMethods
      def ignored?
        if !proxy? && raw_data[:ignored] == true
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
        data = app.extensions[:frontmatter].data(source_file).first

        if proxy?
          url_data = app.extensions[:frontmatter].data(File.join(app.source_dir, url).chomp('/')).first
          data     = data.deep_merge(url_data)
        end

        data
      end

      # This page's frontmatter
      # @return [Hash]
      def data
        @enhanced_data ||= ::Middleman::Util.recursively_enhance(raw_data).freeze
      end

      # Override Resource#content_type to take into account frontmatter
      def content_type
        # Allow setting content type in frontmatter too
        raw_data.fetch :content_type do
          super
        end
      end
    end

    helpers do
      # Get the template data from a path
      # @param [String] path
      # @return [String]
      def template_data_for_file(path)
        extensions[:frontmatter].data(path).last
      end
    end

    def data(path)
      p = normalize_path(path)
      @cache[p] ||= begin
        data, content = frontmatter_and_content(p)

        if app.files.exists?("#{path}.frontmatter")
          external_data, = frontmatter_and_content("#{p}.frontmatter")
          data = external_data.deep_merge(data)
        end

        [data, content]
      end
    end

    def clear_data(file)
      # Copied from Sitemap::Store#file_to_path, but without
      # removing the file extension
      file = File.join(app.root, file)
      prefix = app.source_dir.sub(/\/$/, '') + '/'
      return unless file.include?(prefix)
      path = file.sub(prefix, '').sub(/\.frontmatter$/, '')

      @cache.delete(path)
    end

    private

    # Parse YAML frontmatter out of a string
    # @param [String] content
    # @return [Array<Hash, String>]
    def parse_yaml_front_matter(content, full_path)
      yaml_regex = /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
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

    def parse_json_front_matter(content, full_path)
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
    # @return [Array<Thor::CoreExt::HashWithIndifferentAccess, String>]
    def frontmatter_and_content(path)
      full_path = if Pathname(path).relative?
        File.join(app.source_dir, path)
      else
        path
      end

      data = {}

      return [data, nil] if !app.files.exists?(full_path) || ::Middleman::Util.binary?(full_path)

      # Avoid weird race condition when a file is renamed.
      content = begin
        read_data_file(full_path)
      rescue ::EOFError
      rescue ::IOError
      rescue ::Errno::ENOENT
        ''
      end

      begin
        if content =~ /\A.*coding:/
          lines = content.split(/\n/)
          lines.shift
          content = lines.join("\n")
        end

        result = parse_yaml_front_matter(content, full_path) || parse_json_front_matter(content, full_path)
        return result if result
      rescue
        # Probably a binary file, move on
      end

      [data, content]
    end

    def read_data_file(path)
      data = File.open(path, 'rb') { |io| io.read }
      if data.respond_to?(:force_encoding)
        # Set it to the default external (without verifying)
        data.force_encoding(Encoding.default_external) if Encoding.default_external
      end
      data
    end

    def normalize_path(path)
      path.sub(%r{^#{Regexp.escape(app.source_dir)}\/}, '')
    end
  end
end
