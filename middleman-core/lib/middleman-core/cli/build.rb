# Use Rack::Test for inspecting a running server for output
require "rack"
require "rack/test"

# CLI Module
module Middleman::Cli
  
  # The CLI Build class
  class Build < Thor
    include Thor::Actions
    
    check_unknown_options!
    
    namespace :build
    
    desc "build [options]", "Builds the static site for deployment"
    method_option :relative, 
      :type    => :boolean, 
      :aliases => "-r", 
      :default => false, 
      :desc    => 'Force relative urls'
    method_option :clean, 
      :type    => :boolean, 
      :aliases => "-c", 
      :default => false, 
      :desc    => 'Removes orpahand files or directories from build'
    method_option :glob, 
      :type    => :string, 
      :aliases => "-g", 
      :default => nil, 
      :desc    => 'Build a subset of the project'
    
    # Core build Thor command
    # @return [void]
    def build
      if !ENV["MM_ROOT"]
        $stderr.puts "== Error: Could not find a Middleman project config, perhaps you are in the wrong folder?"
        exit(1)
      end
      
      if options.has_key?("relative") && options["relative"]
        self.class.shared_instance.activate :relative_assets
      end
    
      self.class.shared_rack

      opts = {}
      opts[:glob]  = options["glob"]  if options.has_key?("glob")
      opts[:clean] = options["clean"] if options.has_key?("clean")

      action GlobAction.new(self, opts)

      self.class.shared_instance.run_hook :after_build, self
    end
    
    # Static methods
    class << self
      
      # Middleman::Base singleton
      #
      # @return [Middleman::Base]
      def shared_instance
        @_shared_instance ||= ::Middleman.server.inst do
          set :environment, :build
        end
      end
      
      # Middleman::Base class singleton
      #
      # @return [Middleman::Base]
      def shared_server
        @_shared_server ||= shared_instance.class
      end
      
      # Rack::Test::Session singleton
      #
      # @return [Rack::Test::Session]
      def shared_rack
        @_shared_rack ||= begin
          mock = ::Rack::MockSession.new(shared_server.to_rack_app)
          sess = ::Rack::Test::Session.new(mock)
          response = sess.get("__middleman__")
          sess
        end
      end
    end
    
    # Set the root path to the Middleman::Base's root
    source_root(shared_instance.root)
    # Render a template to a file.
    #
    # @param [String] source
    # @param [String] destination
    # @param [Hash] config
    # @return [String] the actual destination file path that was created
    desc "", "", :hide => true
    def tilt_template(source, destination, config={})
      build_dir = self.class.shared_instance.build_dir
      request_path = destination.sub(/^#{build_dir}/, "")
      config[:force] = true

      begin
        destination, request_path = self.class.shared_instance.reroute_builder(destination, request_path)

        response = self.class.shared_rack.get(request_path.gsub(/\s/, "%20"))

        create_file(destination, response.body, config)

        destination
      rescue
        say_status :error, destination, :red
        abort
      end
    end
  end
  
  # A Thor Action, modular code, which does the majority of the work.
  class GlobAction < ::Thor::Actions::EmptyDirectory
    attr_reader :source

    # Setup the action
    #
    # @param [Middleman::Cli::Build] base
    # @param [Hash] config
    def initialize(base, config={})
      @app         = base.class.shared_instance
      source       = @app.source
      @destination = @app.build_dir

      @source = File.expand_path(base.find_in_source_paths(source.to_s))

      super(base, @destination, config)
    end
    
    # Execute the action
    # @return [void]
    def invoke!
      queue_current_paths if cleaning?
      execute!
      clean! if cleaning?
    end

  protected
    # Remove files which were not built in this cycle
    # @return [void]
    def clean!
      files       = @cleaning_queue.select { |q| File.file? q }
      directories = @cleaning_queue.select { |q| File.directory? q }

      files.each do |f| 
        base.remove_file f, :force => true
      end

      directories = directories.sort_by {|d| d.length }.reverse!

      directories.each do |d|
        base.remove_file d, :force => true if directory_empty? d 
      end
    end

    # Whether we should clean the build
    # @return [Boolean]
    def cleaning?
      @config.has_key?(:clean) && @config[:clean]
    end

    # Whether the given directory is empty
    # @param [String] directory
    # @return [Boolean]
    def directory_empty?(directory)
      Dir[File.join(directory, "*")].empty?
    end

    # Get a list of all the paths in the destination folder and save them
    # for comparison against the files we build in this cycle
    # @return [void]
    def queue_current_paths
      @cleaning_queue = []
      Find.find(@destination) do |path|
        next if path.match(/\/\./) && !path.match(/\.htaccess/)
        unless path == destination
          @cleaning_queue << path.sub(@destination, destination[/([^\/]+?)$/])
        end
      end if File.exist?(@destination)
    end

    # Actually build the app
    # @return [void]
    def execute!
      # Sort order, images, fonts, js/css and finally everything else.
      sort_order = %w(.png .jpeg .jpg .gif .bmp .svg .svgz .ico .woff .otf .ttf .eot .js .css)

      # Sort paths to be built by the above order. This is primarily so Compass can
      # find files in the build folder when it needs to generate sprites for the
      # css files
      paths = @app.sitemap.all_paths.sort do |a, b|
        a_ext = File.extname(a)
        b_ext = File.extname(b)

        a_idx = sort_order.index(a_ext) || 100
        b_idx = sort_order.index(b_ext) || 100

        a_idx <=> b_idx
      end

      # Loop over all the paths and build them.
      paths.each do |path|
        file_source = path
        file_destination = File.join(given_destination, file_source.gsub(source, '.'))
        file_destination.gsub!('/./', '/')

        if @app.sitemap.proxied?(file_source)
          file_source = @app.sitemap.page(file_source).proxied_to
        elsif @app.sitemap.ignored?(file_source)
          next
        end
        
        next if @config[:glob] && !File.fnmatch(@config[:glob], file_source)

        file_destination = base.tilt_template(file_source, file_destination)

        @cleaning_queue.delete(file_destination) if cleaning?
      end
    end
  end
  
  # Alias "b" to "build"
  Base.map({ "b" => "build" })
end