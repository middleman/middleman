require 'stylus'
require 'stylus/tilt'

module Middleman
  module Renderers
    class Stylus < ::Middleman::Extension
      define_setting :styl, {}, 'Stylus config options'
    end
  end
end
