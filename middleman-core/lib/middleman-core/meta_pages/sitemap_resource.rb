module Middleman
  module MetaPages
    # View class for a sitemap resource
    class SitemapResource
      def initialize(resource)
        @resource = resource
      end

      def render
        "<p>#{@resource.destination_path}</p>"
      end
    end
  end
end
