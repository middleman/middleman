# Sitemap namespace
module Middleman::Sitemap
  
  # The Store class
  #
  # The Store manages a collection of Page objects, which represent
  # individual items in the sitemap. Pages are indexed by "source path",
  # which is the path relative to the source directory, minus any template
  # extensions. All "path" parameters used in this class are source paths.
  class Base
    
    # @return [Middleman::Base]
    attr_accessor :app
    
    # @return [Array<Middleman::Sitemap::Page>]
    attr_accessor :pages
    
    # Initialize with parent app
    # @param [Middleman::Base] app
    def initialize(app)
      @app   = app
      @pages = []
      
      # Register classes which can manipulate the main site map list
      @page_list_manipulators = []
      register_page_list_manipulator(Middleman::Sitemap::Extensions::OnDisk,  false)
      register_page_list_manipulator(Middleman::Sitemap::Extensions::Proxies, false)
      register_page_list_manipulator(Middleman::Sitemap::Extensions::Ignores, false)
      rebuild_page_list!(:after_base_init)
    end

    # Register a klass which can manipulate the main site map list
    # @param [Class] klass
    # @param [Boolean] immediately_rebuild
    # @return [void]
    def register_page_list_manipulator(klass, immediately_rebuild=true)
      @page_list_manipulators << klass.new(self)
      rebuild_page_list!(:registered_new) if immediately_rebuild
    end
    
    # Rebuild the list of pages from scratch, using registed manipulators
    # @return [void]
    def rebuild_page_list!(reason=nil)
      # $stderr.puts "STARTING: #{reason}"
      @pages = []
      @page_list_manipulators.each(&:manipulate_page_list!)
    end

    # Check to see if we know about a specific path
    # @param [String] path
    # @return [Boolean]
    def exists?(path)
      @pages.has_key? normalize_path(path)
    end
    
    # Find a page given its destination path
    # @param [String] The destination (output) path of a page.
    # @return [Middleman::Sitemap::Page]
    def [](destination_path)
      destination_path = normalize_path(destination_path)
      @pages.find do |p|
        p.path == destination_path# || p.destination_path == destination_path.sub("/#{@app.index_file}", "")
      end
    end

    # Normalize a path to not include a leading slash
    # @param [String] path
    # @return [String]
    def normalize_path(path)
      path.sub(/^\//, "").gsub("%20", " ")
    end
  end
end