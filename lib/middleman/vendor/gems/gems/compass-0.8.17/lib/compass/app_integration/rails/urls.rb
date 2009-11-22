module Compass::SassExtensions::Functions::Urls
  def image_url_with_rails_integration(path)
    if (@controller = Sass::Plugin.rails_controller) && @controller.respond_to?(:request) && @controller.request
      begin
        Sass::Script::String.new "url(#{image_path(path.value)})"
      ensure
        @controller = nil
      end
    else
      image_url_without_rails_integration(path)
    end
  end
  alias_method_chain :image_url, :rails_integration
end