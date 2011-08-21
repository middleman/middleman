require 'sinatra/base'
require 'padrino-core/support_lite' unless defined?(SupportLite)

FileSet.glob_require('padrino-core/application/*.rb', __FILE__)
FileSet.glob_require('padrino-core/*.rb', __FILE__)

# Defines our Constants
PADRINO_ENV  = ENV["PADRINO_ENV"]  ||= ENV["RACK_ENV"] ||= "development"  unless defined?(PADRINO_ENV)
PADRINO_ROOT = ENV["PADRINO_ROOT"] ||= File.dirname(Padrino.first_caller) unless defined?(PADRINO_ROOT)

module Padrino
  class ApplicationLoadError < RuntimeError #:nodoc:
  end

  class << self
    ##
    # Helper method for file references.
    #
    # ==== Examples
    #
    #   # Referencing a file in config called settings.yml
    #   Padrino.root("config", "settings.yml")
    #   # returns PADRINO_ROOT + "/config/setting.yml"
    #
    def root(*args)
      File.expand_path(File.join(PADRINO_ROOT, *args))
    end

    ##
    # Helper method that return PADRINO_ENV
    #
    def env
      @_env ||= PADRINO_ENV.to_s.downcase.to_sym
    end

    ##
    # Returns the resulting rack builder mapping each 'mounted' application
    #
    def application
      raise ApplicationLoadError, "At least one app must be mounted!" unless Padrino.mounted_apps && Padrino.mounted_apps.any?
      router = Padrino::Router.new
      Padrino.mounted_apps.each { |app| app.map_onto(router) }

      unless middleware.empty?
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
    #   Padrino.configure_apps do
    #     enable  :sessions
    #     disable :raise_errors
    #   end
    #
    def configure_apps(&block)
      @_global_configuration = block if block_given?
    end

    ###
    # Returns project-wide configuration settings
    # defined in 'configure_apps' block
    #
    def apps_configuration
      @_global_configuration
    end

    ##
    # Default encoding to UTF8.
    #
    def set_encoding
      if RUBY_VERSION < '1.9'
        $KCODE='u'
      else
        Encoding.default_external = Encoding::UTF_8
        Encoding.default_internal = nil # Encoding::UTF_8
      end
      nil
    end

    ##
    # Return bundle status :+:locked+ if .bundle/environment.rb exist :+:unlocked if Gemfile exist
    # otherwise return nil
    #
    def bundle
      return :locked   if File.exist?(root('Gemfile.lock'))
      return :unlocked if File.exist?(root("Gemfile"))
    end

    ##
    # A Rack::Builder object that allows to add middlewares in front of all
    # Padrino applications
    #
    def middleware
      @middleware ||= []
    end

    ##
    # Clears all previously configured middlewares
    #
    def clear_middleware!
      @middleware = []
    end

    ##
    # Convenience method for adding a Middleware to the whole padrino app.
    #
    def use(m, *args, &block)
      middleware << [m, args, block]
    end
  end # self
end # Padrino