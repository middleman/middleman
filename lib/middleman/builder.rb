require "thor"
require "thor/group"
require "rack/test"
require "find"

module Middleman
  class Builder < Thor::Group
    include Thor::Actions
    
    class << self
      def shared_instance
        @_shared_instance ||= ::Middleman.server.inst do
          set :environment, :build
        end
      end
      
      def shared_server
        @_shared_server ||= shared_instance.class
      end
      
      def shared_rack
        @_shared_rack ||= begin
          mock = ::Rack::MockSession.new(shared_server.to_rack_app)
          sess = ::Rack::Test::Session.new(mock)
          response = sess.get("__middleman__")
          sess
        end
      end
    end
    
    # @private
    module ThorActions
      # Render a template to a file.
      # @return [String] the actual destination file path that was created
      def tilt_template(source, *args, &block)
        config = args.last.is_a?(Hash) ? args.pop : {}
        destination = args.first || source

        request_path = destination.sub(/^#{::Middleman::Builder.shared_instance.build_dir}/, "")

        # begin
          destination, request_path = ::Middleman::Builder.shared_instance.reroute_builder(destination, request_path)

          response = ::Middleman::Builder.shared_rack.get(request_path.gsub(/\s/, "%20"))
          create_file(destination, response.body, config) if response.status == 200

          destination
        # rescue
          # say_status :error, destination, :red
        # end
      end
    end
    include ThorActions
    
    class_option :relative, :type => :boolean, :aliases => "-r", :default => false, :desc => 'Override the config.rb file and force relative urls'
    class_option :glob, :type => :string, :aliases => "-g", :default => nil, :desc => 'Build a subset of the project'
    
    def initialize(*args)
      super
      
      if options.has_key?("relative") && options["relative"]
        self.class.shared_instance.activate :relative_assets
      end
    end
    
    def source_paths
      @source_paths ||= [
        self.class.shared_instance.root
      ]
    end
    
    def build_all_files
      self.class.shared_rack
      
      opts = { }
      opts[:glob]  = options["glob"]  if options.has_key?("glob")
      opts[:clean] = options["clean"] if options.has_key?("clean")
      
      action GlobAction.new(self, self.class.shared_instance, opts)
      
      self.class.shared_instance.run_hook :after_build, self
    end
  end
  
  # @private
  class GlobAction < ::Thor::Actions::EmptyDirectory
    attr_reader :source

    def initialize(base, app, config={}, &block)
      @app         = app
      source       = @app.source
      @destination = @app.build_dir
      
      @source = File.expand_path(base.find_in_source_paths(source.to_s))
      
      super(base, destination, config)
    end

    def invoke!
      queue_current_paths if cleaning?
      execute!
      clean! if cleaning?
    end

    def revoke!
      execute!
    end

  protected
  
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
  
    def cleaning?
      @config.has_key?(:clean) && @config[:clean]
    end

    def directory_empty?(directory)
      Dir[File.join(directory, "*")].empty?
    end

    def queue_current_paths
      @cleaning_queue = []
      Find.find(@destination) do |path|
        next if path.match(/\/\./) && !path.match(/\.htaccess/)
        unless path == destination
          @cleaning_queue << path.sub(@destination, destination[/([^\/]+?)$/])
        end
      end if File.exist?(@destination)
    end
    
    def execute!
      sort_order = %w(.png .jpeg .jpg .gif .bmp .svg .svgz .ico .woff .otf .ttf .eot .js .css)
      
      paths = @app.sitemap.all_paths.sort do |a, b|
        a_ext = File.extname(a)
        b_ext = File.extname(b)
        
        a_idx = sort_order.index(a_ext) || 100
        b_idx = sort_order.index(b_ext) || 100
        
        a_idx <=> b_idx
      end
      
      paths.each do |path|
        file_source = path
        file_destination = File.join(given_destination, file_source.gsub(source, '.'))
        file_destination.gsub!('/./', '/')

        if @app.sitemap.generic?(file_source)
          # no-op
        elsif @app.sitemap.proxied?(file_source)
          file_source = @app.sitemap.page(file_source).proxied_to
        elsif @app.sitemap.ignored?(file_source)
          next
        end
        
        if @config[:glob]
          next unless File.fnmatch(@config[:glob], file_source)
        end
        
        file_destination = base.tilt_template(file_source, file_destination, { :force => true })

        @cleaning_queue.delete(file_destination) if cleaning?
      end
    end
  end
end
