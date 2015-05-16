require 'middleman-core/sitemap/store'
require 'middleman-core/sitemap/resource'

require 'middleman-core/sitemap/extensions/on_disk'
require 'middleman-core/sitemap/extensions/redirects'
require 'middleman-core/sitemap/extensions/request_endpoints'
require 'middleman-core/sitemap/extensions/proxies'
require 'middleman-core/sitemap/extensions/ignores'

# Core Sitemap Extensions
module Middleman
  module Sitemap
    # Setup Extension
    class << self
      # Once registered
      def registered(app)
        app.register Middleman::Sitemap::Extensions::RequestEndpoints
        app.register Middleman::Sitemap::Extensions::Proxies
        app.register Middleman::Sitemap::Extensions::Ignores
        app.register Middleman::Sitemap::Extensions::Redirects

        # Set to automatically convert some characters into a directory
        app.config.define_setting :automatic_directory_matcher, nil, 'Set to automatically convert some characters into a directory'

        # Setup callbacks which can exclude paths from the sitemap
        app.config.define_setting :ignored_sitemap_matchers, {
          # dotfiles and folders in the root
          root_dotfiles: proc { |file| file.start_with?('.') },

          # Files starting with an dot, but not .htaccess
          source_dotfiles: proc do |file|
            file =~ %r{/\.} && file !~ %r{/\.(htaccess|htpasswd|nojekyll)}
          end,

          # Files starting with an underscore, but not a double-underscore
          partials: proc { |file| file =~ %r{/_[^_]} },

          layout: proc do |file, sitemap_app|
            file.start_with?(File.join(sitemap_app.config[:source], 'layout.')) || file.start_with?(File.join(sitemap_app.config[:source], 'layouts/'))
          end
        }, 'Callbacks that can exclude paths from the sitemap'

        # Include instance methods
        app.send :include, InstanceMethods

        # Initialize Sitemap
        app.before_configuration do
          sitemap
        end
      end
      alias_method :included, :registered
    end

    # Sitemap instance methods
    module InstanceMethods
      # Get the sitemap class instance
      # @return [Middleman::Sitemap::Store]
      def sitemap
        @_sitemap ||= Store.new(self)
      end

      # Get the resource object for the current path
      # @return [Middleman::Sitemap::Resource]
      def current_page
        current_resource
      end

      # Get the resource object for the current path
      # @return [Middleman::Sitemap::Resource]
      def current_resource
        return nil unless current_path
        sitemap.find_resource_by_destination_path(current_path)
      end
    end
  end
end
