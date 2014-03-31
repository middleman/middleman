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
    # @param [Hash] options Data to pass through.
    # @return [String]
    def asset_url(path, prefix='', options={})
      path = super

      requested_resource = options[:current_resource] || current_resource

      if path.include?('//') || path.start_with?('data:') || !requested_resource
        path
      else
        current_dir = Pathname('/' + requested_resource.destination_path)
        Pathname(path).relative_path_from(current_dir.dirname).to_s
      end
    end
  end
end
