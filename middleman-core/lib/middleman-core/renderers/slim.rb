# frozen_string_literal: true

# Load gem
require 'slim'

module SafeTemplate
  def render(*)
    super.html_safe
  end
end

module SlimTemplatePatch
  def initialize(file = nil, line = nil, opts = {}, &block)
    if opts.key?(:context)
      ::Slim::Embedded::SassEngine.disable_option_validator!
      %w[sass scss markdown].each do |engine|
        (::Slim::Embedded.options[engine.to_sym] ||= {})[:context] = opts[:context]
      end
    end

    super
  end

  def precompiled_preamble(locals)
    original = super
    "__in_slim_template = true\n#{original}"
  end
end

::Slim::Template.include SafeTemplate
::Slim::Template.prepend SlimTemplatePatch

module Middleman
  module Renderers
    # Slim renderer
    class Slim < ::Middleman::Extension
      # Setup extension
      def initialize(_app, _options_hash = ::Middleman::EMPTY_HASH, &_block)
        super

        # Setup Slim options to work with partials
        ::Slim::Engine.disable_option_validator!
        ::Slim::Engine.set_options(
          buffer: '@_out_buf',
          use_html_safe: true,
          generator: ::Temple::Generators::RailsOutputBuffer,
          disable_escape: true
        )
      end
    end
  end
end
