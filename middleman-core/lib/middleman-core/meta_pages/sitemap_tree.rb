require 'middleman-core/meta_pages/sitemap_resource'

module Middleman
  module MetaPages
    # View class for a sitemap tree
    class SitemapTree
      def initialize
        @children = {}
      end

      def add_resource(resource)
        add_path(resource.path.split('/'), resource)
      end

      def render
        content = ""
        @children.keys.sort_by(&:downcase).each do |path_part|
          content << "<details>"
          content << "<summary>"
          content << path_part
          content << "</summary>"

          subtree = @children[path_part]
          content << subtree.render
          content << "</details>"
        end
        content
      end

      protected

      def add_path(path_parts, resource)
        first_part = path_parts.first

        if path_parts.size == 1
          @children[first_part] = SitemapResource.new(resource)
        else
          @children[first_part] ||= SitemapTree.new
          @children[first_part].add_path(path_parts[1..-1], resource)
        end
      end

      def to_s
        "Sitemap Tree"
      end
    end
  end
end
