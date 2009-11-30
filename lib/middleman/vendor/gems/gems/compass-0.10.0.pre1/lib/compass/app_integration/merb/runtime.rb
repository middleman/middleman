# To configure Merb to use compass do the following:
# 
# Add dependencies to config/dependencies.rb
# 
# dependency "haml", ">=2.2.0" 
# dependency "merb-haml", merb_gems_version
# dependency "chriseppstein-compass", :require_as => 'compass'
# 
# 
# To use a different sass stylesheets locations as is recommended by compass
# add this configuration to your configuration block:
#
# Merb::BootLoader.before_app_loads do
#   Merb::Plugins.config[:compass] = {
#     :stylesheets => "app/stylesheets",
#     :compiled_stylesheets => "public/stylesheets/compiled"
#   }
# end
# 
module Compass
  def self.setup_template_location
    # default the compass configuration if they didn't set it up yet.
    Merb::Plugins.config[:compass] ||= {}

    # default sass stylesheet location unless configured to something else
    Merb::Plugins.config[:compass][:stylesheets] ||= Merb.dir_for(:stylesheet) / "sass"

    # default sass css location unless configured to something else
    Merb::Plugins.config[:compass][:compiled_stylesheets] ||= Merb.dir_for(:stylesheet)

    #define the template hash for the project stylesheets as well as the framework stylesheets.
    template_location = {
      Merb::Plugins.config[:compass][:stylesheets] => Merb::Plugins.config[:compass][:compiled_stylesheets]
    }
    Compass::Frameworks::ALL.each do |framework|
      template_location[framework.stylesheets_directory] = Merb::Plugins.config[:compass][:compiled_stylesheets]
    end

    # merge existing template locations if present
    if Merb::Plugins.config[:sass][:template_location].is_a?(Hash)
      template_location.merge!(Merb::Plugins.config[:sass][:template_location])
      Merb::Plugins.config[:sass][:template_location] = template_location
    end

    #configure Sass to know about all these sass locations.
    Sass::Plugin.options[:template_location] = template_location
  end
end

Merb::BootLoader.after_app_loads do
  #set up sass if haml load didn't do it -- this happens when using a non-default stylesheet location.
  unless defined?(Sass::Plugin)
    require "sass/plugin" 
    if Merb::Plugins.config[:sass]
      Sass::Plugin.options = Merb::Plugins.config[:sass] 
    # support old (deprecatd Merb::Config[:sass] option)
    elsif Merb::Config[:sass] 
      Sass::Plugin.options = Merb::Config[:sass] 
    end
  end

  Compass.setup_template_location
end
