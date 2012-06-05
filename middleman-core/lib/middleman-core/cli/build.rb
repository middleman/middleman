require "middleman-core"

# CLI Module
module Middleman::Cli
  
  # The CLI Build class
  class Build < Thor
    include Thor::Actions
    
    attr_reader :debugging
    
    check_unknown_options!
    
    namespace :build
    
    desc "build [options]", "Builds the static site for deployment"
    method_option :clean, 
      :type    => :boolean, 
      :aliases => "-c", 
      :default => false, 
      :desc    => 'Removes orphaned files or directories from build'
    method_option :glob, 
      :type    => :string, 
      :aliases => "-g", 
      :default => nil, 
      :desc    => 'Build a subset of the project'
    method_option :verbose,
      :type    => :boolean, 
      :default => false,
      :desc    => 'Print debug messages'
    
    # Core build Thor command
    # @return [void]
    def build
      if !ENV["MM_ROOT"]
        raise Thor::Error, "Error: Could not find a Middleman project config, perhaps you are in the wrong folder?"
      end
      
      # Use Rack::Test for inspecting a running server for output
      require "rack"
      require "rack/test"

      require 'find'
      
      @debugging = Middleman::Cli::Base.debugging
      @had_errors = false
      
      self.class.shared_instance(options["verbose"])
      
      self.class.shared_rack

      opts = {}
      opts[:glob]  = options["glob"]  if options.has_key?("glob")
      opts[:clean] = options["clean"] if options.has_key?("clean")

      action GlobAction.new(self, opts)

      if @had_errors && !@debugging
        self.shell.say "There were errors during this build, re-run with --debug to see the full exception."
      end
      
      exit(1) if @had_errors

      self.class.shared_instance.run_hook :after_build, self
    end
    
    # Static methods
    class << self
      def exit_on_failure?
        true
      end

      # Middleman::Application singleton
      #
      # @return [Middleman::Application]
      def shared_instance(verbose=false)
        @_shared_instance ||= ::Middleman::Application.server.inst do
          set :environment, :build
          set :logging,     verbose
        end
      end
      
      # Middleman::Application class singleton
      #
      # @return [Middleman::Application]
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
    
      # Set the root path to the Middleman::Application's root
      def source_root
        shared_instance.root
      end
    end
    
    no_tasks {
      # Render a resource to a file.
      #
      # @param [Middleman::Sitemap::Resource] resource
      # @return [String] The full path of the file that was written
      def render_to_file(resource)
        build_dir = self.class.shared_instance.build_dir
        output_file = File.join(build_dir, resource.destination_path)

        begin
          response = self.class.shared_rack.get(URI.escape(resource.destination_path))

          if response.status == 200
            create_file(output_file, response.body)
          else
            handle_error(output_file, response.body)
          end
        rescue => e
          handle_error(output_file, "#{e}\n#{e.backtrace.join("\n")}", e)
        end

        output_file
      end
    
      def handle_error(file_name, response, e=Thor::Error.new(response))
        @had_errors = true
        
        say_status :error, file_name, :red
        if self.debugging
          raise e
          exit(1)
        elsif options["verbose"]
          self.shell.error(response)
        end
      end
    }
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
      files       = @cleaning_queue.select { |q| q.file? }
      directories = @cleaning_queue.select { |q| q.directory? }

      files.each do |f| 
        base.remove_file f, :force => true
      end

      directories = directories.sort_by {|d| d.to_s.length }.reverse!

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
      directory.children.empty?
    end

    # Get a list of all the paths in the destination folder and save them
    # for comparison against the files we build in this cycle
    # @return [void]
    def queue_current_paths
      @cleaning_queue = []
      Find.find(@destination) do |path|
        next if path.match(/\/\./) && !path.match(/\.htaccess/)
        unless path == destination
          @cleaning_queue << Pathname.new(path)
        end
      end if File.exist?(@destination)
    end

    # Actually build the app
    # @return [void]
    def execute!
      # Sort order, images, fonts, js/css and finally everything else.
      sort_order = %w(.png .jpeg .jpg .gif .bmp .svg .svgz .ico .woff .otf .ttf .eot .js .css)
      
      # Pre-request CSS to give Compass a chance to build sprites
      puts "== Prerendering CSS" if @app.logging?

      @app.sitemap.resources.select do |resource|
        resource.ext == ".css"
      end.each do |resource|
        Middleman::Cli::Build.shared_rack.get(URI.escape(resource.destination_path))
      end
      
      puts "== Checking for Compass sprites" if @app.logging?

      # Double-check for compass sprites
      @app.files.find_new_files(Pathname.new(@app.source_dir) + @app.images_dir)

      # Sort paths to be built by the above order. This is primarily so Compass can
      # find files in the build folder when it needs to generate sprites for the
      # css files

      puts "== Building files" if @app.logging?

      resources = @app.sitemap.resources.sort do |a, b|
        a_idx = sort_order.index(a.ext) || 100
        b_idx = sort_order.index(b.ext) || 100

        a_idx <=> b_idx
      end

      # Loop over all the paths and build them.
      resources.each do |resource|
        next if @config[:glob] && !File.fnmatch(@config[:glob], resource.destination_path)

        output_path = base.render_to_file(resource)

        @cleaning_queue.delete(Pathname.new(output_path).realpath) if cleaning?
      end
    end
  end
  
  # Alias "b" to "build"
  Base.map({ "b" => "build" })
end

# Quiet down create file
class ::Thor::Actions::CreateFile
  def on_conflict_behavior(&block)
    say_status :create, :green
    block.call unless pretend?
  end
end