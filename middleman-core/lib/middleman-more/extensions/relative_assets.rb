# Relative Assets extension
class Middleman::Extensions::RelativeAssets < ::Middleman::Extension
  def initialize(app, options_hash={}, &block)
    super

    # After compass is setup, make it use the registered cache buster
    app.compass_config do |config|
      config.relative_assets = true
    end if app.respond_to?(:compass_config)
  end

  helpers do
    # asset_url override for relative assets
    # @param [String] path
    # @param [String] prefix
    # @param [Hash] options Additional options.
    # @return [String]
    def asset_url(path, prefix='', options={})
      options[:relative] = true unless options.key?(:relative)

      super(path, prefix, options)
    end
  end
end
