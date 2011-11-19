module Middleman::Features::AssetHost
  class << self
    def registered(app)
      app.compass_config do |config|
        if app.asset_host.is_a?(Proc)
          config.asset_host(&app.asset_host)
        end
      end

      app.register_asset_handler :asset_host do |path, prefix|
        original_output = self.before_asset_handler(:asset_host, path, prefix)

        valid_extensions = %w(.png .gif .jpg .jpeg .js .css)

        asset_prefix = self.asset_host.call(original_output)

        File.join(asset_prefix, original_output)
      end
    end
    alias :included :registered
  end
end