# Core Sitemap Extensions
module Middleman
  module Sitemap
    # Setup Extension
    class << self
      # Once registered
      def included(app)
        # Set to automatically convert some characters into a directory
        app.config.define_setting :automatic_directory_matcher, nil, 'Set to automatically convert some characters into a directory'

        # Setup callbacks which can exclude paths from the sitemap
        app.config.define_setting :ignored_sitemap_matchers, {
          # dotfiles and folders in the root
          root_dotfiles: proc { |file| file.start_with?('.') },

          # Files starting with an dot, but not .htaccess
          source_dotfiles: proc { |file|
            file =~ %r{/\.} && file !~ %r{/\.(htaccess|htpasswd|nojekyll)}
          },

          # Files starting with an underscore, but not a double-underscore
          partials: proc { |file| file =~ %r{/_[^_]} },

          layout: proc { |file, sitemap_app|
            file.start_with?(File.join(sitemap_app.config[:source], 'layout.')) || file.start_with?(File.join(sitemap_app.config[:source], 'layouts/'))
          }
        }, 'Callbacks that can exclude paths from the sitemap'

        # Include instance methods
        ::Middleman::TemplateContext.send :include, InstanceMethods
      end
    end

    # Sitemap instance methods
    module InstanceMethods
      def current_path
        @locs[:current_path]
      end

      # Get the resource object for the current path
      # @return [Middleman::Sitemap::Resource]
      def current_resource
        return nil unless current_path
        sitemap.find_resource_by_destination_path(current_path)
      end
      alias_method :current_page, :current_resource
    end
  end
end
