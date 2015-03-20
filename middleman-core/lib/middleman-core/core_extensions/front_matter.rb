require 'active_support/core_ext/hash/keys'
require 'pathname'

# Parsing YAML frontmatter
require 'yaml'

# Parsing JSON frontmatter
require 'active_support/json'

# Extensions namespace
module Middleman::CoreExtensions
  class FrontMatter < ::Middleman::Extension
    # Try to run after routing but before directory_indexes
    self.resource_list_manipulator_priority = 90

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
      app.files.on_change(:source, &method(:clear_data))
    end

    # @return Array<Middleman::Sitemap::Resource>
    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      resources.each do |resource|
        next if resource.source_file.nil?

        fmdata = data(resource.source_file[:full_path].to_s).first.dup

        # Copy over special options
        # TODO: Should we make people put these under "options" instead of having
        # special known keys?
        opts = fmdata.extract!(:layout, :layout_engine, :renderer_options, :directory_index, :content_type)
        opts[:renderer_options].symbolize_keys! if opts.key?(:renderer_options)

        ignored = fmdata.delete(:ignored)

        # TODO: Enhance data? NOOOO
        # TODO: stringify-keys? immutable/freeze?

        resource.add_metadata options: opts, page: fmdata

        resource.ignore! if ignored == true && !resource.is_a?(::Middleman::Sitemap::ProxyResource)

        # TODO: Save new template here somewhere?
      end
    end

    # Get the template data from a path
    # @param [String] path
    # @return [String]
    Contract String => Maybe[String]
    def template_data_for_file(path)
      data(path).last
    end

    Contract String => [Hash, Maybe[String]]
    def data(path)
      file = app.files.find(:source, path)

      return [{}, nil] unless file

      @cache[file[:full_path]] ||= frontmatter_and_content(file[:full_path])
    end

    Contract ArrayOf[IsA['Middleman::SourceFile']], ArrayOf[IsA['Middleman::SourceFile']] => Any
    def clear_data(updated_files, removed_files)
      (updated_files + removed_files).each do |file|
        @cache.delete(file[:full_path])
      end
    end

    # Get the frontmatter and plain content from a file
    # @param [String] path
    # @return [Array<Middleman::Util::IndifferentHash, String>]
    Contract Pathname => [Hash, Maybe[String]]
    def frontmatter_and_content(full_path)
      data = {}

      return [data, nil] if ::Middleman::Util.binary?(full_path)

      # Avoid weird race condition when a file is renamed.
      content = begin
        File.read(full_path)
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

    private

    # Parse YAML frontmatter out of a string
    # @param [String] content
    # @return [Array<Hash, String>]
    Contract String, Pathname => Maybe[[Hash, String]]
    def parse_yaml_front_matter(content, full_path)
      yaml_regex = /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
      if content =~ yaml_regex
        content = content.sub(yaml_regex, '')

        begin
          data = YAML.load($1) || {}
          data = data.symbolize_keys
        rescue *YAML_ERRORS => e
          app.logger.error "YAML Exception parsing #{full_path}: #{e.message}"
          return nil
        end
      else
        return nil
      end

      [data, content]
    rescue
      [{}, content]
    end

    # Parse JSON frontmatter out of a string
    # @param [String] content
    # @return [Array<Hash, String>]
    Contract String, Pathname => Maybe[[Hash, String]]
    def parse_json_front_matter(content, full_path)
      json_regex = /\A(;;;\s*\n.*?\n?)^(;;;\s*$\n?)/m

      if content =~ json_regex
        content = content.sub(json_regex, '')

        begin
          json = ($1 + $2).sub(';;;', '{').sub(';;;', '}')
          data = ::ActiveSupport::JSON.decode(json).symbolize_keys
        rescue => e
          app.logger.error "JSON Exception parsing #{full_path}: #{e.message}"
          return nil
        end

      else
        return nil
      end

      [data, content]
    rescue
      [{}, content]
    end
  end
end
