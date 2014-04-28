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

    # Modify each resource to add data & options from frontmatter.
    def manipulate_resource_list(resources)
      resources.each do |resource|
        fmdata = data(resource.path).first

        # Copy over special options
        # TODO: Should we make people put these under "options" instead of having
        # special known keys?
        opts = fmdata.extract!(:layout, :layout_engine, :renderer_options, :directory_index, :content_type)
        if opts.has_key?(:renderer_options)
          opts[:renderer_options].symbolize_keys!
        end

        ignored = fmdata.delete(:ignored)

        # TODO: Enhance data? NOOOO
        # TODO: stringify-keys? immutable/freeze?

        resource.add_metadata options: opts, page: fmdata

        # TODO: resource.ignore! if ignored

        # TODO: Save new template here somewhere?
      end
    end

    def after_configuration
      app.ignore %r{\.frontmatter$}
    end

    # Get the template data from a path
    # @param [String] path
    # @return [String]
    def template_data_for_file(path)
      data(path).last
    end

    def data(path)
      p = normalize_path(path)
      @cache[p] ||= begin
        data, content = frontmatter_and_content(p)

        if app.files.exists?("#{path}.frontmatter")
          external_data, _ = frontmatter_and_content("#{p}.frontmatter")
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
    # @return [Array<Middleman::Util::HashWithIndifferentAccess, String>]
    def frontmatter_and_content(path)
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

        result = parse_yaml_front_matter(content, full_path) || parse_json_front_matter(content, full_path)
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
