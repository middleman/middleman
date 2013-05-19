require 'padrino-core/support_lite' unless defined?(SupportLite)
require 'cgi'
require 'i18n'
require 'enumerator'
require 'active_support/time_with_zone'               # next extension depends on this
require 'active_support/core_ext/string/conversions'  # to_date
require 'active_support/core_ext/float/rounding'      # round
require 'active_support/option_merger'                # with_options
require 'active_support/core_ext/object/with_options' # with_options
require 'active_support/inflector'                    # humanize

FileSet.glob_require('padrino-helpers/**/*.rb', __FILE__)

# Load our locales
I18n.load_path += Dir["#{File.dirname(__FILE__)}/padrino-helpers/locale/*.yml"]

module Padrino
  ##
  # This component provides a variety of view helpers related to html markup generation.
  # There are helpers for generating tags, forms, links, images, and more.
  # Most of the basic methods should be very familiar to anyone who has used rails view helpers.
  #
  module Helpers
    class << self
      ##
      # Registers these helpers into your application:
      #
      #   Padrino::Helpers::OutputHelpers
      #   Padrino::Helpers::TagHelpers
      #   Padrino::Helpers::AssetTagHelpers
      #   Padrino::Helpers::FormHelpers
      #   Padrino::Helpers::FormatHelpers
      #   Padrino::Helpers::RenderHelpers
      #   Padrino::Helpers::NumberHelpers
      #
      # @param [Sinatra::Application] app
      #   The specified padrino application
      #
      # @example Register the helper module
      #   require 'padrino-helpers'
      #   class Padrino::Application
      #     register Padrino::Helpers
      #   end
      #
      def registered(app)
        app.set :default_builder, 'StandardFormBuilder'
        app.helpers Padrino::Helpers::OutputHelpers
        app.helpers Padrino::Helpers::TagHelpers
        app.helpers Padrino::Helpers::AssetTagHelpers
        app.helpers Padrino::Helpers::FormHelpers
        app.helpers Padrino::Helpers::FormatHelpers
        app.helpers Padrino::Helpers::RenderHelpers
        app.helpers Padrino::Helpers::NumberHelpers
        app.helpers Padrino::Helpers::TranslationHelpers
      end
      alias :included :registered
    end
  end # Helpers
end # Padrino
