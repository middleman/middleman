module Middleman::Sitemap::Extensions
  # Content type is implemented as a module so it can be overridden by other sitemap extensions
  class Metadata

    attr_reader :resource

    def initialize(resource)
      @resource = resource
      @local_metadata = { options: {}, locals: {}, data: {} }
    end

    # Get the metadata for both the current source_file and the current path
    # @return [Hash]
    def metadata
      # @cached ||= begin
        result = {}

        if resource.source_file
          path_meta = resource.store.metadata_for_path(resource.path).dup
          result.deep_merge!(path_meta)

          file_meta = resource.store.metadata_for_file(resource.source_file).dup
          result.deep_merge!(file_meta)
        end

        local_meta = @local_metadata.dup
        result.deep_merge!(local_meta)

        result
      # end
    end

    def clear
      @cached = nil
    end

    def fetch(key)
      metadata[key]
    end

    # Merge in new metadata specific to this resource.
    # @param [Hash] meta A metadata block like provides_metadata_for_path takes
    def add(meta)
      @local_metadata.deep_merge!(meta.dup)
    end

    # This page's frontmatter without being enhanced for access by either symbols or strings.
    # Used internally
    # @private
    # @return [Hash]
    def raw_data
      metadata[:data]
    end

    # This page's frontmatter
    # @return [Hash]
    def data
      @enhanced_data ||= ::Middleman::Util.recursively_enhance(raw_data).freeze
    end
  end
end
