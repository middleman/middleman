# Extensions namespace
module Middleman
  module Extensions

    # Asset Host module
    module AssetHost

      # Setup extension
      class << self

        # Once registered
        def registered(app, options={})
          app.config.define_setting :asset_host, false, 'The asset host to use, or false for no asset host, or a Proc to determine asset host'

          if options[:host]
            config[:asset_host] = options[:host]
          end

          # Include methods
          app.send :include, InstanceMethods
        end

        alias :included :registered
      end

      # Asset Host Instance Methods
      module InstanceMethods

        # Override default asset url helper to include asset hosts
        #
        # @param [String] path
        # @param [String] prefix
        # @return [String]
        def asset_url(path, prefix="")
          original_output = super
          return original_output unless config[:asset_host]

          asset_prefix = if config[:asset_host].is_a?(Proc)
            config[:asset_host].call(original_output)
          elsif config[:asset_host].is_a?(String)
            config[:asset_host]
          end

          File.join(asset_prefix, original_output)
        end
      end
    end
  end
end
