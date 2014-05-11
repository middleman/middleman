module Middleman
  module Sitemap
    module Extensions

      # Add metadata to Resources based on path matchers. This exists
      # entirely to support the "page" method in config.rb.

      # TODO: This requires the concept of priority for sitemap manipulators
      # in order for it to always run after all other manipulators.
      class MetadataForPath
        def initialize(sitemap)
          @app = sitemap.app
        end
      end
    end
  end
end
