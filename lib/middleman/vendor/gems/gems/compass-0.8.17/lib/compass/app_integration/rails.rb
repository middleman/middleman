unless defined?(Compass::RAILS_LOADED)
  Compass::RAILS_LOADED = true
  require File.join(File.dirname(__FILE__), 'rails', 'action_controller')
  require File.join(File.dirname(__FILE__), 'rails', 'sass_plugin')
  require File.join(File.dirname(__FILE__), 'rails', 'urls')
  # Wierd that this has to be re-included to pick up sub-modules. Ruby bug?
  class Sass::Script::Functions::EvaluationContext
    include Sass::Script::Functions
    private
    include ActionView::Helpers::AssetTagHelper
  end
end
