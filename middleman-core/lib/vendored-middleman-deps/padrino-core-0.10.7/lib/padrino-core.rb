require 'sinatra/base'
require 'padrino-core/support_lite' unless defined?(SupportLite)

FileSet.glob_require('padrino-core/application/*.rb', __FILE__)
FileSet.glob_require('padrino-core/*.rb', __FILE__)

# The Padrino environment (falls back to the rack env or finally develop)
PADRINO_ENV  = ENV["PADRINO_ENV"]  ||= ENV["RACK_ENV"] ||= "development"  unless defined?(PADRINO_ENV)
# The Padrino project root path (falls back to the first caller)
PADRINO_ROOT = ENV["PADRINO_ROOT"] ||= File.dirname(Padrino.first_caller) unless defined?(PADRINO_ROOT)

module Padrino
  class ApplicationLoadError < RuntimeError # @private
  end

  class << self
    ##
    # Helper method for file references.
    #
    # @param [Array<String>] args
    #   The directories to join to {PADRINO_ROOT}.
    #
    # @return [String]
    #   The absolute path.
    #
    # @example
    #   # Referencing a file in config called settings.yml
    #   Padrino.root("config", "settings.yml")
    #   # returns PADRINO_ROOT + "/config/setting.yml"
    #
    def root(*args)
      File.expand_path(File.join(PADRINO_ROOT, *args))
    end

    ##
    # Helper method that return {PADRINO_ENV}.
    #
    # @return [Symbol]
    #   The Padrino Environment.
    #
    def env
      @_env ||= PADRINO_ENV.to_s.downcase.to_sym
    end

    ##
    # The resulting rack builder mapping each 'mounted' application.
    #
    # @return [Padrino::Router]
    #   The router for the application.
    #
    # @raise [ApplicationLoadError]
    #   No applications were mounted.
    #
    def application
      raise ApplicationLoadError, "At least one app must be mounted!" unless Padrino.mounted_apps && Padrino.mounted_apps.any?
      router = Padrino::Router.new
      Padrino.mounted_apps.each { |app| app.map_onto(router) }

      if middleware.present?
        builder = Rack::Builder.new
        middleware.each { |c,a,b| builder.use(c, *a, &b) }
        builder.run(router)
        builder.to_app
      else
        router
      end
    end

    ##
    # Configure Global Project Settings for mounted apps. These can be overloaded
    # in each individual app's own personal configuration. This can be used like:
    #
    # @yield []
    #   The given block will be called to configure each application.
    #
    # @example
    #   Padrino.configure_apps do
    #     enable  :sessions
    #     disable :raise_errors
    #   end
    #
    def configure_apps(&block)
      @_global_configuration = block if block_given?
    end

    ##
    # Returns project-wide configuration settings defined in
    # {configure_apps} block.
    #
    def apps_configuration
      @_global_configuration
    end

    ##
    # Set +Encoding.default_internal+ and +Encoding.default_external+
    # to +Encoding::UFT_8+.
    #
    # Please note that in +1.9.2+ with some template engines like +haml+
    # you should turn off Encoding.default_internal to prevent problems.
    #
    # @see https://github.com/rtomayko/tilt/issues/75
    #
    # @return [NilClass]
    #
    def set_encoding
      if RUBY_VERSION < '1.9'
        $KCODE='u'
      else
        Encoding.default_external = Encoding::UTF_8
        Encoding.default_internal = Encoding::UTF_8
      end
      nil
    end

    ##
    # A Rack::Builder object that allows to add middlewares in front of all
    # Padrino applications.
    #
    # @return [Array<Array<Class, Array, Proc>>]
    #   The middleware classes.
    #
    def middleware
      @middleware ||= []
    end

    ##
    # Clears all previously configured middlewares.
    #
    # @return [Array]
    #   An empty array
    #
    def clear_middleware!
      @middleware = []
    end

    ##
    # Convenience method for adding a Middleware to the whole padrino app.
    #
    # @param [Class] m
    #   The middleware class.
    #
    # @param [Array] args
    #   The arguments for the middleware.
    #
    # @yield []
    #   The given block will be passed to the initialized middleware.
    #
    def use(m, *args, &block)
      middleware << [m, args, block]
    end
  end # self
end # Padrino
