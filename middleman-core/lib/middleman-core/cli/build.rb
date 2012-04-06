# Use Rack::Test for inspecting a running server for output
require "rack"
require "rack/test"

require 'find'

# CLI Module
module Middleman::Cli
  
  # The CLI Build class
  class Build < Thor
    include Thor::Actions
    
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
        raise Thor::Error "Error: Could not find a Middleman project config, perhaps you are in the wrong folder?"
      end
      
      self.class.shared_instance(options["verbose"] || false)
      
      self.class.shared_rack

      opts = {}
      opts[:glob]  = options["glob"]  if options.has_key?("glob")
      opts[:clean] = options["clean"] if options.has_key?("clean")

      action GlobAction.new(self, opts)

      self.class.shared_instance.run_hook :after_build, self
    end
    
    # Static methods
    class << self
      def exit_on_failure?
        true
      end

      # Middleman::Base singleton
      #
      # @return [Middleman::Base]
      def shared_instance(verbose=false)
        @_shared_instance ||= ::Middleman.server.inst do
          set :environment, :build
          set :logging,     verbose
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
    
      # Set the root path to the Middleman::Base's root
      def source_root
        shared_instance.root
      end
    end
    
    # Ignore following method
    desc "", "", :hide => true
    
    # Render a page to a file.
    #
    # @param [Middleman::Sitemap::Page] page
    # @return [void]
    def render_to_file(page)
      build_dir = self.class.shared_instance.build_dir
      output_file = File.join(self.class.shared_instance.build_dir, page.destination_path)

      begin
        response = self.class.shared_rack.get(page.request_path.gsub(/\s/, "%20"))
        if response.status == 200
          create_file(output_file, response.body, { :force => true })
        else
          raise Thor::Error.new response.body
        end
      rescue => e
        say_status :error, output_file, :red
        raise Thor::Error.new "#{e}\n#{e.backtrace.join("\n")}"
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
      @app.sitemap.pages.select do |p|
        p.ext == ".css"
      end.each do |p|
        Middleman::Cli::Build.shared_rack.get(p.request_path.gsub(/\s/, "%20"))
      end
      
      # Double-check for compass sprites
      @app.files.reload_path(File.join(@app.source_dir, @app.images_dir))

      # Sort paths to be built by the above order. This is primarily so Compass can
      # find files in the build folder when it needs to generate sprites for the
      # css files

      pages = @app.sitemap.pages.sort do |a, b|
        a_idx = sort_order.index(a.ext) || 100
        b_idx = sort_order.index(b.ext) || 100

        a_idx <=> b_idx
      end

      # Loop over all the paths and build them.
      pages.each do |page|
        next if page.ignored?
        next if @config[:glob] && !File.fnmatch(@config[:glob], page.path)

        base.render_to_file(page)

        output_path = File.join(@destination, page.destination_path)
        @cleaning_queue.delete(Pathname.new(output_path).realpath) if cleaning?
      end
    end
  end
  
  # Alias "b" to "build"
  Base.map({ "b" => "build" })
end
