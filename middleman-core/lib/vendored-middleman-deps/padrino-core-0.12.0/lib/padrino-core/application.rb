require 'padrino-core/application/flash'
require 'padrino-core/application/rendering'
require 'padrino-core/application/routing'
require 'padrino-core/application/show_exceptions'
require 'padrino-core/application/authenticity_token'

module Padrino
  ##
  # Subclasses of this become independent Padrino applications
  # (stemming from Sinatra::Application).
  # These subclassed applications can be easily mounted into other
  # Padrino applications as well.
  #
  class Application < Sinatra::Base
    # Support for advanced routing, controllers, url_for
    register Padrino::Routing

    ##
    # Returns the logger for this application.
    #
    # @return [Padrino::Logger] Logger associated with this app.
    #
    def logger
      Padrino.logger
    end

    # TODO: Remove this hack after getting rid of thread-unsafe http_router:
    alias_method :original_call, :call
    def call(*args)
      settings.init_mutex.synchronize do
        instance_eval{ undef :call }
        class_eval{ alias_method :call, :original_call }
        instance_eval{ undef :original_call }
        super(*args)
      end
    end

    class << self
      def inherited(base)
        begun_at = Time.now
        CALLERS_TO_IGNORE.concat(PADRINO_IGNORE_CALLERS)
        base.default_configuration!
        logger.devel :setup, begun_at, base
        super(base)
      end

      ##
      # Reloads the application files from all defined load paths.
      #
      # This method is used from our Padrino Reloader during development mode
      # in order to reload the source files.
      #
      # @return [TrueClass]
      #
      # @example
      #   MyApp.reload!
      #
      def reload!
        logger.devel "Reloading application #{settings}"
        reset!
        reset_router!
        Padrino.require_dependencies(settings.app_file, :force => true)
        require_dependencies
        default_filters!
        default_routes!
        default_errors!
        I18n.reload! if defined?(I18n)
        true
      end

      ##
      # Resets application routes to only routes not defined by the user.
      #
      # @return [TrueClass]
      #
      # @example
      #   MyApp.reset_routes!
      #
      def reset_routes!
        reset_router!
        default_routes!
        true
      end

      ##
      # Returns the routes of our app.
      #
      # @example
      #   MyApp.routes
      #
      def routes
        router.routes
      end

      ##
      # Returns an absolute path of view in application views folder.
      #
      # @example
      #   Admin.view_path 'users/index' #=> "/home/user/test/admin/views/users/index"
      #
      def view_path(view)
        File.expand_path(view, views)
      end

      ##
      # Returns an absolute path of application layout.
      #
      # @example
      #   Admin.layout_path :application #=> "/home/user/test/admin/views/layouts/application"
      #
      def layout_path(layout)
        view_path("layouts/#{layout}")
      end

      ##
      # Setup the application by registering initializers, load paths and logger.
      # Invoked automatically when an application is first instantiated.
      #
      # @return [TrueClass]
      #
      def setup_application!
        return if @_configured
        settings.require_dependencies
        settings.default_filters!
        settings.default_routes!
        settings.default_errors!
        if defined?(I18n)
          Reloader.special_files += settings.locale_path
          I18n.load_path << settings.locale_path
          I18n.reload!
        end
        @_configured = true
      end

      ##
      # Run the Padrino app as a self-hosted server using
      # Thin, Mongrel or WEBrick (in that order).
      #
      # @see Padrino::Server#start
      #
      def run!(options={})
        return unless Padrino.load!
        Padrino.mount(settings.to_s).to('/')
        Padrino.run!(options)
      end

      ##
      # @return [Array]
      #   directory that need to be added to +$LOAD_PATHS+ from this application
      #
      def load_paths
        @_load_paths ||= [
          'models',
          'lib',
          'mailers',
          'controllers',
          'helpers',
        ].map { |path| File.join(settings.root, path) }
      end

      ##
      # Returns default list of path globs to load as dependencies.
      # Appends custom dependency patterns to the be loaded for your Application.
      #
      # @return [Array]
      #   list of path globs to load as dependencies
      #
      # @example
      #   MyApp.dependencies << "#{Padrino.root}/uploaders/**/*.rb"
      #   MyApp.dependencies << Padrino.root('other_app', 'controllers.rb')
      #
      def dependencies
        [
          'urls.rb',
          'config/urls.rb',
          'mailers/*.rb',
          'mailers.rb',
          'controllers/**/*.rb',
          'controllers.rb',
          'helpers/**/*.rb',
          'helpers.rb',
        ].map { |file| Dir[File.join(settings.root, file)] }.flatten
      end

      ##
      # An array of file to load before your app.rb, basically are files
      # which our app depends on.
      #
      # By default we look for files:
      #
      #   # List of default files that we are looking for:
      #   yourapp/models.rb
      #   yourapp/models/**/*.rb
      #   yourapp/lib.rb
      #   yourapp/lib/**/*.rb
      #
      # @example Adding a custom prerequisite
      #   MyApp.prerequisites << Padrino.root('my_app', 'custom_model.rb')
      #
      def prerequisites
        @_prerequisites ||= []
      end

      def default(option, *args, &block)
        set(option, *args, &block) unless respond_to?(option)
      end

      protected

      ##
      # Defines default settings for Padrino application.
      #
      def default_configuration!
        set :app_file, File.expand_path(caller_files.first || $0)
        set :app_name, settings.to_s.underscore.to_sym

        set :environment, Padrino.env
        set :reload, Proc.new { development? }
        set :logging, Proc.new { development? }

        set :method_override, true
        set :default_builder, 'StandardFormBuilder'

        # TODO: Remove this hack after getting rid of thread-unsafe http_router:
        set :init_mutex, Mutex.new

        # TODO: Remove this line after sinatra version up.
        set :add_charset, %w[javascript xml xhtml+xml].map {|t| "application/#{t}" }

        default_paths!
        default_security!
        global_configuration!
        setup_prerequisites!
      end

      def setup_prerequisites!
        prerequisites.concat(default_prerequisites).uniq!
        Padrino.require_dependencies(prerequisites)
      end

      def default_paths!
        set :locale_path,   Proc.new { Dir.glob File.join(root, 'locale/**/*.{rb,yml}') }
        set :views,         Proc.new { File.join(root, 'views') }

        set :uri_root,      '/'
        set :public_folder, Proc.new { Padrino.root('public', uri_root) }
        set :images_path,   Proc.new { File.join(public_folder, 'images') }
      end
      
      def default_security!
        set :protection, :except => :path_traversal
        set :authentication, false
        set :sessions, false
        set :protect_from_csrf, false
        set :allow_disabled_csrf, false
      end

      ##
      # Applies global padrino configuration blocks to current application.
      #
      def global_configuration!
        Padrino.global_configurations.each do |configuration|
          class_eval(&configuration)
        end
      end

      ##
      # We need to add almost __sinatra__ images.
      #
      def default_routes!
        configure :development do
          get '*__sinatra__/:image.png' do
            content_type :png
            filename = File.dirname(__FILE__) + "/images/#{params[:image]}.png"
            send_file filename
          end
        end
      end

      ##
      # This filter it's used for know the format of the request, and
      # automatically set the content type.
      #
      def default_filters!
        before do
          response['Content-Type'] = 'text/html;charset=utf-8' unless @_content_type
        end
      end

      ##
      # This log errors for production environments.
      #
      def default_errors!
        configure :production do
          error ::Exception do
            boom = env['sinatra.error']
            logger.error ["#{boom.class} - #{boom.message}:", *boom.backtrace].join("\n ")
            response.status = 500
            content_type 'text/html'
            '<h1>Internal Server Error</h1>'
          end unless errors.has_key?(::Exception)
        end
      end

      ##
      # Requires all files within the application load paths.
      #
      def require_dependencies
        Padrino.set_load_paths(*load_paths)
        Padrino.require_dependencies(dependencies, :force => true)
      end

      ##
      # Returns globs of default paths of application prerequisites.
      #
      def default_prerequisites
        [
          '/models.rb',
          '/models/**/*.rb',
          '/lib.rb',
          '/lib/**/*.rb',
        ].map{ |glob| File.join(settings.root, glob) }
      end

      private

      # Overrides the default middleware for Sinatra based on Padrino conventions.
      # Also initializes the application after setting up the middleware.
      def setup_default_middleware(builder)
        setup_sessions builder
        builder.use Padrino::ShowExceptions         if show_exceptions?
        builder.use Padrino::Logger::Rack, uri_root if Padrino.logger && logging?
        builder.use Padrino::Reloader::Rack         if reload?
        builder.use Rack::MethodOverride            if method_override?
        builder.use Rack::Head
        register    Padrino::Flash
        setup_protection builder
        setup_csrf_protection builder
        setup_application!
      end

      # sets up csrf protection for the app:
      def setup_csrf_protection(builder)
        check_csrf_protection_dependency

        if protect_from_csrf?
          options = options_for_csrf_protection_setup
          options.merge!(protect_from_csrf) if protect_from_csrf.kind_of?(Hash)
          builder.use(options[:except] ? Padrino::AuthenticityToken : Rack::Protection::AuthenticityToken, options)
        end
      end

      # returns the options used in the builder for csrf protection setup
      def options_for_csrf_protection_setup
        options = { :logger => logger }

        if allow_disabled_csrf?
          options.merge!({
                             :reaction   => :report,
                             :report_key => 'protection.csrf.failed'
                         })
        end
        options
      end

      # throw an exception if the protect_from_csrf is active but sessions not.
      def check_csrf_protection_dependency
        if (protect_from_csrf? && !sessions?) && !defined?(Padrino::IGNORE_CSRF_SETUP_WARNING)
          warn(<<-ERROR)
`protect_from_csrf` is activated, but `sessions` seem to be off. To enable csrf
protection, use:

    enable :sessions

or deactivate protect_from_csrf:

    disable :protect_from_csrf

If you use a different session store, ignore this warning using:

    # in boot.rb:
    Padrino::IGNORE_CSRF_SETUP_WARNING = true
          ERROR
        end
      end
    end
  end
end
