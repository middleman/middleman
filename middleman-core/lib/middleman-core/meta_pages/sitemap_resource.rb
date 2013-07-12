if !defined?(::Padrino::Helpers)
  require 'vendored-middleman-deps/padrino-core-0.11.2/lib/padrino-core/support_lite'
  require 'vendored-middleman-deps/padrino-helpers-0.11.2/lib/padrino-helpers'
end

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
        content_tag :div, :class => 'resource-details' do
          content_tag :table do
            content = ""
            resource_properties.each do |label, value|
              content << content_tag(:tr) do
                row_content = ""
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
        props = {
          'Path' => @resource.path,
          'Build Path' => @resource.destination_path,
          'URL' => content_tag(:a, @resource.url, :href => @resource.url),
          'Source File' => @resource.source_file,
        }

        data = @resource.data
        props['Data'] = data unless data.empty?

        options = @resource.metadata[:options]
        props['Options'] = options unless options.empty?

        props
      end

      def css_classes
        ['resource']
      end
    end
  end
end
