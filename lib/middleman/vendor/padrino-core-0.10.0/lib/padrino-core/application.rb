module Padrino
  class ApplicationSetupError < RuntimeError #:nodoc:
  end

  ##
  # Subclasses of this become independent Padrino applications (stemming from Sinatra::Application)
  # These subclassed applications can be easily mounted into other Padrino applications as well.
  #
  class Application < Sinatra::Base
    register Padrino::Routing   # Support for advanced routing, controllers, url_for

    class << self

      def inherited(base) #:nodoc:
        logger.devel "Setup #{base}"
        CALLERS_TO_IGNORE.concat(PADRINO_IGNORE_CALLERS)
        base.default_configuration!
        base.prerequisites.concat([
          File.join(base.root, "/models.rb"),
          File.join(base.root, "/models/**/*.rb"),
          File.join(base.root, "/lib.rb"),
          File.join(base.root, "/lib/**/*.rb")
        ]).uniq!
        Padrino.require_dependencies(base.prerequisites)
        super(base) # Loading the subclass inherited method
      end

      ##
      # Hooks into when a new instance of the application is created
      # This is used because putting the configuration into inherited doesn't
      # take into account overwritten app settings inside subclassed definitions
      # Only performs the setup first time application is initialized.
      #
      def new(*args, &bk)
        setup_application!
        logging, logging_was = false, logging
        show_exceptions, show_exceptions_was = false, show_exceptions
        super(*args, &bk)
      ensure
        logging, show_exceptions = logging_was, show_exceptions_was
      end

      ##
      # Reloads the application files from all defined load paths
      #
      # This method is used from our Padrino Reloader during development mode
      # in order to reload the source files.
      #
      # ==== Examples
      #
      #   MyApp.reload!
      #
      def reload!
        logger.devel "Reloading #{self}"
        @_dependencies = nil # Reset dependencies
        reset! # Reset sinatra app
        reset_routes! # Remove all existing user-defined application routes
        Padrino.require_dependencies(self.app_file, :force => true) # Reload the app file
        require_dependencies # Reload dependencies
        register_initializers # Reload our middlewares
        default_filters! # Reload filters
        default_errors!  # Reload our errors
        I18n.reload! if defined?(I18n) # Reload also our translations
      end

      ##
      # Resets application routes to only routes not defined by the user
      #
      # ==== Examples
      #
      #   MyApp.reset_routes!
      #
      def reset_routes!
        reset_router!
        default_routes!
      end

      ##
      # Returns the routes of our app.
      #
      # ==== Examples
      #
      #   MyApp.routes
      #
      def routes
        router.routes
      end

      ##
      # Setup the application by registering initializers, load paths and logger
      # Invoked automatically when an application is first instantiated
      #
      def setup_application!
        return if @_configured
        self.register_initializers
        self.require_dependencies
        self.disable :logging # We need do that as default because Sinatra use commonlogger.
        self.default_filters!
        self.default_routes!
        self.default_errors!
        if defined?(I18n)
          I18n.load_path << self.locale_path
          I18n.reload!
        end
        @_configured = true
      end

      ##
      # Run the Padrino app as a self-hosted server using
      # Thin, Mongrel or WEBrick (in that order)
      #
      def run!(options={})
        return unless Padrino.load!
        Padrino.mount(self.to_s).to("/")
        Padrino.run!(options)
      end

      ##
      # Returns the used $LOAD_PATHS from this application
      #
      def load_paths
        @_load_paths ||= %w(models lib mailers controllers helpers).map { |path| File.join(self.root, path) }
      end

      ##
      # Returns default list of path globs to load as dependencies
      # Appends custom dependency patterns to the be loaded for your Application
      #
      # ==== Examples
      #   MyApp.dependencies << "#{Padrino.root}/uploaders/**/*.rb"
      #   MyApp.dependencies << Padrino.root('other_app', 'controllers.rb')
      #
      def dependencies
        @_dependencies ||= [
          "urls.rb", "config/urls.rb", "mailers/*.rb", "mailers.rb",
          "controllers/**/*.rb", "controllers.rb", "helpers/**/*.rb", "helpers.rb"
        ].map { |file| Dir[File.join(self.root, file)] }.flatten
      end

      ##
      # An array of file to load before your app.rb, basically are files wich our app depends on.
      #
      # By default we look for files:
      #
      #   yourapp/models.rb
      #   yourapp/models/**/*.rb
      #   yourapp/lib.rb
      #   yourapp/lib/**/*.rb
      #
      # ==== Examples
      #   MyApp.prerequisites << Padrino.root('my_app', 'custom_model.rb')
      #
      def prerequisites
        @_prerequisites ||= []
      end

      protected
        ##
        # Defines default settings for Padrino application
        #
        def default_configuration!
          # Overwriting Sinatra defaults
          set :app_file, File.expand_path(caller_files.first || $0) # Assume app file is first caller
          set :environment, Padrino.env
          set :reload, Proc.new { development? }
          set :logging, Proc.new { development? }
          set :method_override, true
          set :sessions, false
          set :public, Proc.new { Padrino.root('public', uri_root) }
          set :views, Proc.new { File.join(root,   "views") }
          set :images_path, Proc.new { File.join(public, "images") }
          # Padrino specific
          set :uri_root, "/"
          set :app_name, self.to_s.underscore.to_sym
          set :default_builder, 'StandardFormBuilder'
          set :flash, defined?(Rack::Flash)
          set :authentication, false
          # Padrino locale
          set :locale_path, Proc.new { Dir[File.join(self.root, "/locale/**/*.{rb,yml}")] }
          # Load the Global Configurations
          class_eval(&Padrino.apps_configuration) if Padrino.apps_configuration
        end

        ##
        # We need to add almost __sinatra__ images.
        #
        def default_routes!
          configure :development do
            get '/__sinatra__/:image.png' do
              content_type :png
              filename = File.dirname(__FILE__) + "/images/#{params[:image]}.png"
              send_file filename
            end
          end
        end

        ##
        # This filter it's used for know the format of the request, and automatically set the content type.
        #
        def default_filters!
          before do
            unless @_content_type
              @_content_type = :html
              response['Content-Type'] = 'text/html;charset=utf-8'
            end
          end
        end

        ##
        # This log errors for production environments
        #
        def default_errors!
          configure :production do
            error ::Exception do
              boom = env['sinatra.error']
              logger.error ["#{boom.class} - #{boom.message}:", *boom.backtrace].join("\n ")
              response.status = 500
              content_type 'text/html'
              '<h1>Internal Server Error</h1>'
            end
          end
        end

        ##
        # Requires the Padrino middleware
        #
        def register_initializers
          use Padrino::ShowExceptions         if show_exceptions?
          use Padrino::Logger::Rack, uri_root if Padrino.logger && logging?
          use Padrino::Reloader::Rack         if reload?
          use Rack::Flash, :sweep => true     if flash?
        end

        ##
        # Requires all files within the application load paths
        #
        def require_dependencies
          Padrino.set_load_paths(*load_paths)
          Padrino.require_dependencies(dependencies, :force => true)
        end
    end # self

    # TODO Remove deprecated render inclusion in a few versions
    # Detects if a user is incorrectly using 'render' and warns them about the fix
    # In 0.10.0, Padrino::Rendering now has to be explicitly included in the application
    def render(*args)
      if !defined?(DEFAULT_RENDERING_OPTIONS) && !@_render_included &&
          (args.size == 1 || (args.size == 2 && args[0].is_a?(String) && args[1].is_a?(Hash)))
        logger.warn "[Deprecation] Please 'register Padrino::Rendering' for each application as shown here:
          https://gist.github.com/1d36a35794dbbd664ea4 for 'render' to function as expected"
        self.class.instance_eval { register Padrino::Rendering }
        @_render_included = true
        render(*args)
      else # pass through, rendering is valid
        super(*args)
      end
    end # render method
  end # Application
end # Padrino