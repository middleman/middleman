module Compass::SassExtensions::Functions
end

['selectors', 'enumerate', 'urls', 'display', 'inline_image'].each do |func|
  require File.join(File.dirname(__FILE__), 'functions', func)
end

module Sass::Script::Functions
  include Compass::SassExtensions::Functions::Selectors
  include Compass::SassExtensions::Functions::Enumerate
  include Compass::SassExtensions::Functions::Urls
  include Compass::SassExtensions::Functions::Display
  include Compass::SassExtensions::Functions::InlineImage
end

# Wierd that this has to be re-included to pick up sub-modules. Ruby bug?
class Sass::Script::Functions::EvaluationContext
  include Sass::Script::Functions
end
