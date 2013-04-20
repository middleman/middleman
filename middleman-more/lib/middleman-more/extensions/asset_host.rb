# Extensions namespace
module Middleman
  module Extensions

    # Asset Host module
    class AssetHost < ::Middleman::Extension
      option :host, nil, 'The asset host to use, or false for no asset host, or a Proc to determine asset host'

      def initialize(app, options_hash={}, &block)
        super

        # Backwards compatible API
        app.config.define_setting :asset_host, nil, 'The asset host to use, or false for no asset host, or a Proc to determine asset host'
        app.send :include, InstanceMethods
      end

      def host
        app.config[:asset_host] || options[:host]
      end

      # Asset Host Instance Methods
      module InstanceMethods

        # Override default asset url helper to include asset hosts
        #
        # @param [String] path
        # @param [String] prefix
        # @return [String]
        def asset_url(path, prefix="")
          controller = extensions[:asset_host]

          original_output = super
          return original_output unless controller.host

          asset_prefix = if controller.host.is_a?(Proc)
            controller.host.call(original_output)
          elsif controller.host.is_a?(String)
            controller.host
          end

          File.join(asset_prefix, original_output)
        end
      end
    end
  end
end
