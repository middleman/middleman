require 'padrino-helpers'

module Middleman
  module MetaPages
    # View class for a sitemap resource
    class SitemapResource
      include Padrino::Helpers::OutputHelpers
      include Padrino::Helpers::TagHelpers

      def initialize(resource)
        @resource = resource
      end

      def render
        classes = 'resource-details'
        classes << ' ignored' if @resource.ignored?
        content_tag :div, class: classes do
          content_tag :table do
            content = ''
            resource_properties.each do |label, value|
              content << content_tag(:tr) do
                row_content = ''
                row_content << content_tag(:th, label)
                row_content << content_tag(:td, value)
                row_content.html_safe
              end
            end
            content.html_safe
          end
        end
      end

      # A hash of label to value for all the properties we want to display
      def resource_properties
        props = {}
        props['Path'] = @resource.path

        build_path = @resource.destination_path
        build_path = 'Not built' if ignored?
        props['Build Path'] = build_path if @resource.path != build_path
        props['URL'] = content_tag(:a, @resource.url, href: @resource.url) unless ignored?
        props['Source File'] = @resource.source_file ? @resource.source_file.sub(/^#{Regexp.escape(ENV['MM_ROOT'] + '/')}/, '') : 'Dynamic'

        data = @resource.data
        props['Data'] = data.inspect unless data.empty?

        meta = @resource.metadata
        options = meta[:options]
        props['Options'] = options.inspect unless options.empty?

        locals = meta[:locals].keys
        props['Locals'] = locals.join(', ') unless locals.empty?

        props
      end

      def ignored?
        @resource.ignored?
      end

      def css_classes
        ['resource'].concat(ignored? ? ['ignored'] : [])
      end
    end
  end
end
