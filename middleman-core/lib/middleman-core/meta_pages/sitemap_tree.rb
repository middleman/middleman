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
        sorted_children_keys = @children.keys.sort do |a, b|
          a_subtree = @children[a]
          b_subtree = @children[b]
          if a_subtree.is_a? SitemapResource
            if b_subtree.is_a? SitemapResource
              a.downcase <=> b.downcase
            else
              1
            end
          elsif b_subtree.is_a? SitemapResource
            if a_subtree.is_a? SitemapResource
              b.downcase <=> a.downcase
            else
              -1
            end
          else
            a.downcase <=> b.downcase
          end
        end

        sorted_children_keys.reduce('') do |content, path_part|
          subtree = @children[path_part]
          content << "<details class='#{subtree.css_classes.join(' ')}'>"
          content << '<summary>'
          content << "<i class='icon-folder-open'></i>" unless subtree.is_a? SitemapResource
          content << "#{path_part}</summary>"
          content << subtree.render
          content << '</details>'
        end
      end

      def css_classes
        ['tree'].concat(ignored? ? ['ignored'] : [])
      end

      def ignored?
        @children.values.all?(&:ignored?)
      end

      protected

      def add_path(path_parts, resource)
        first_part = path_parts.first

        if path_parts.size == 1
          sitemap_class = SitemapResource
          # Allow special sitemap resources to use custom metadata view calsses
          sitemap_class = resource.meta_pages_class if resource.respond_to? :meta_pages_class

          @children[first_part] = sitemap_class.new(resource)
        else
          @children[first_part] ||= SitemapTree.new
          @children[first_part].add_path(path_parts[1..-1], resource)
        end
      end

      def to_s
        'Sitemap Tree'
      end
    end
  end
end
