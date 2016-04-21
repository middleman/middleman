# Core Pathname library used for traversal
require 'pathname'

# DbC
require 'middleman-core/contracts'

require 'active_support/core_ext/hash/keys'

require 'middleman-core/util/data'

# Extensions namespace
module Middleman::CoreExtensions
  class FrontMatter < ::Middleman::Extension
    # Try to run after routing but before directory_indexes
    self.resource_list_manipulator_priority = 20

    # Set textual delimiters that denote the start and end of frontmatter
    define_setting :frontmatter_delims, {
      json: [%w(;;; ;;;)],
      yaml: [%w(--- ---), %w(--- ...)]
    }, 'Allowed frontmatter delimiters'

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
        next if resource.binary?
        next if resource.file_descriptor.nil?
        next if resource.file_descriptor[:types].include?(:no_frontmatter)

        fmdata = data(resource.file_descriptor[:full_path].to_s).first.dup

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

      file_path = file[:full_path].to_s

      @cache[file_path] ||= begin
        ::Middleman::Util::Data.parse(
          file,
          app.config[:frontmatter_delims]
        )
      end
    end

    Contract ArrayOf[IsA['Middleman::SourceFile']], ArrayOf[IsA['Middleman::SourceFile']] => Any
    def clear_data(updated_files, removed_files)
      (updated_files + removed_files).each do |file|
        @cache.delete(file[:full_path].to_s)
      end
    end
  end
end
