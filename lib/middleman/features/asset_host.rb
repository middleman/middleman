class Middleman::Features::AssetHost
  def initialize(app, config)
    Middleman::Server.after_feature_init do
      if Middleman::Server.asset_host.is_a?(Proc)
        ::Compass.configuration.asset_host(&Middleman::Server.asset_host)
      end
    end
    
    Middleman::Assets.register :asset_host do |path, prefix, request|
      original_output = Middleman::Assets.before(:asset_host, path, prefix, request)

      valid_extensions = %w(.png .gif .jpg .jpeg .js .css)

      asset_prefix = Middleman::Server.asset_host.call(original_output)

      File.join(asset_prefix, original_output)
    end
  end
end

Middleman::Features.register :asset_host, Middleman::Features::AssetHost
