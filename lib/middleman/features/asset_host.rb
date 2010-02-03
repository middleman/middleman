class Middleman::Base
  after_feature_init do
    ::Compass.configuration do |config|
      config.asset_host(&self.asset_host)
    end
  end if self.enabled?(:asset_host)
end

class << Middleman::Base
  alias_method :pre_asset_host_asset_url, :asset_url
  def asset_url(path, prefix="", request=nil)
    original_output = pre_asset_host_asset_url(path, prefix, request)
    
    valid_extensions = %w(.png .gif .jpg .jpeg .js .css)
    
    if !self.enabled?(:asset_host) || path.include?("://") || !valid_extensions.include?(File.extname(path)) || !self.asset_host
      return original_output
    end

    asset_prefix = if self.asset_host.is_a?(Proc) || self.asset_host.respond_to?(:call)
      self.asset_host.call(original_output)
    else
      (self.asset_host =~ /%d/) ? self.asset_host % (original_output.hash % 4) : self.asset_host
    end
    
    return File.join(asset_prefix, original_output)
  end
end
