if RUBY_VERSION < "3.2"
  require "active_support/version"

  require "logger" if ActiveSupport.version < Gem::Version.new("8.0.0")
end

require 'active_support/all'

require 'middleman-core/application'
require 'middleman-core/sources'
require 'middleman-core/sitemap/resource'
require 'middleman-core/util/binary'
require 'middleman-core/util/data'
require 'middleman-core/util/files'
require 'middleman-core/util/paths'
require 'middleman-core/util/rack'
require 'middleman-core/util/uri_templates'

module Middleman
  module Util
    module_function

    # Facade for ActiveSupport/Notification
    def instrument(name, payload={}, &block)
      suffixed_name = name =~ /\.middleman$/ ? name.dup : "#{name}.middleman"
      ::ActiveSupport::Notifications.instrument(suffixed_name, payload, &block)
    end
  end
end
