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
          content_tag :dl do
            content = ""
            resource_properties.each do |label, value|
              content << content_tag(:dt, label)
              content << content_tag(:dd, value)
            end
            content
          end
        end
      end

      # A hash of label to value for all the properties we want to display
      def resource_properties
        {
          'Path' => @resource.path,
          'Output Path' => File.join(@resource.app.build_dir, @resource.destination_path),
          'Url' => content_tag(:a, @resource.url, :href => @resource.url),
          #'Metadata' => @resource.metadata,
          'Source' => @resource.source_file
        }
      end

      def css_classes
        ['resource']
      end
    end
  end
end
