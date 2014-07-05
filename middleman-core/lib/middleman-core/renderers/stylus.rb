require 'stylus'
require 'stylus/tilt'

module Middleman
  module Renderers
    class Stylus < ::Middleman::Extension
      def initialize(app, options={}, &block)
        super

        app.config.define_setting :styl, {}, 'Stylus config options'
      end
    end
  end
end
