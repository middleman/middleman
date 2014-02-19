require 'sinatra/base'
require 'padrino-core/version'
require 'padrino-core/support_lite'
require 'padrino-core/application'

require 'padrino-core/caller'
require 'padrino-core/command'
require 'padrino-core/loader'
require 'padrino-core/logger'
require 'padrino-core/mounter'
require 'padrino-core/reloader'
require 'padrino-core/router'
require 'padrino-core/server'
require 'padrino-core/tasks'
require 'padrino-core/module'

if ENV["PADRINO_ENV"]
  warn 'Environment variable PADRINO_ENV is deprecated. Please, use RACK_ENV.'
  ENV["RACK_ENV"] ||= ENV["PADRINO_ENV"]
end
RACK_ENV = ENV["RACK_ENV"] ||= "development"  unless defined?(RACK_ENV)
PADRINO_ROOT = ENV["PADRINO_ROOT"] ||= File.dirname(Padrino.first_caller) unless defined?(PADRINO_ROOT)

module Padrino
  class ApplicationLoadError < RuntimeError # @private
  end

  extend Loader

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
    # Helper method that return {RACK_ENV}.
    #
    # @return [Symbol]
    #   The Padrino Environment.
    #
    def env
      @_env ||= RACK_ENV.to_s.downcase.to_sym
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
      raise ApplicationLoadError, "At least one app must be mounted!" unless Padrino.mounted_apps.present?
      router = Padrino::Router.new
      Padrino.mounted_apps.each { |app| app.map_onto(router) }
      middleware.present? ? add_middleware(router) : router
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
      return  unless block_given?
      global_configurations << block
    end

    ##
    # Stores global configuration blocks.
    #
    def global_configurations
      @_global_configurations ||= []
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
      Encoding.default_external = Encoding::UTF_8
      Encoding.default_internal = Encoding::UTF_8
      nil
    end

    ##
    # Creates Rack stack with the router added to the middleware chain.
    #
    def add_middleware(router)
      builder = Rack::Builder.new
      middleware.each{ |mw,args,block| builder.use(mw, *args, &block) }
      builder.run(router)
      builder.to_app
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
    def use(mw, *args, &block)
      middleware << [mw, args, block]
    end

    ##
    # Registers a gem with padrino. This relieves the caller from setting up
    # loadpaths by itself and enables Padrino to look up apps in gem folder.
    #
    # The name given has to be the proper gem name as given in the gemspec.
    #
    # @param [String] name
    #   The name of the gem being registered.
    #
    # @param [Module] main_module
    #   The main module of the gem.
    #
    # @returns The root path of the loaded gem
    def gem(name, main_module)
      _, spec = Gem.loaded_specs.find{|spec_pair| spec_pair[0] == name }
      gems << spec
      modules << main_module
      spec.full_gem_path
    end

    ##
    # @returns [Gem::Specification]
    def gems
      @gems ||= []
    end

    ##
    # @returns [<Padrino::Module>]
    def modules
      @modules ||= []
    end
  end
end
