require "thor"
require "thor/group"
require 'rack/test'
require 'find'

SHARED_SERVER = Middleman.server
SHARED_SERVER.set :environment, :build

module Middleman
  module ThorActions
    def tilt_template(source, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      destination = args.first || source
      
      # source  = File.expand_path(find_in_source_paths(source.to_s))
      # context = instance_eval('binding')
      
      request_path = destination.sub(/^#{SHARED_SERVER.build_dir}/, "")
      
      begin
        destination, request_path = SHARED_SERVER.reroute_builder(destination, request_path)
        
        request_path.gsub!(/\s/, "%20")
        response = Middleman::Builder.shared_rack.get(request_path)
        
        dequeue_file_from destination if cleaning?

        create_file destination, nil, config do
          response.body
        end if response.status == 200
      rescue
      end
    end
    
    
    def clean!(destination)
      return unless cleaning?
      queue_current_paths_from destination
      add_clean_up_callback
    end
    
    def cleaning?
      options.has_key?("clean") && options["clean"]
    end
    
    def add_clean_up_callback
      clean_up_callback = lambda do 
        files       = @cleaning_queue.select { |q| File.file? q }
        directories = @cleaning_queue.select { |q| File.directory? q }

        files.each { |f| remove_file f, :force => true }

        directories = directories.sort_by {|d| d.length }.reverse!

        directories.each do |d|
          remove_file d, :force => true if directory_empty? d 
        end
      end
      self.class.after_run :clean_up_callback do
        clean_up_callback.call
      end
    end

    def directory_empty?(directory)
      Dir["#{directory}/*"].empty?
    end

    def queue_current_paths_from(destination)
      @cleaning_queue = []
      Find.find(destination) do |path|
        unless path == destination
          @cleaning_queue << path.sub(destination, destination[/([^\/]+?)$/])
        end
      end
    end

    def dequeue_file_from(destination)
      @cleaning_queue.delete_if {|q| q == destination }
    end
    
  end
  
  class Builder < Thor::Group
    include Thor::Actions
    include Middleman::ThorActions
    
    def self.shared_rack
      @shared_rack ||= begin
        mock = ::Rack::MockSession.new(SHARED_SERVER)
        sess = ::Rack::Test::Session.new(mock)
        response = sess.get("__middleman__")
        sess
      end
    end
    
    class_option :relative, :type => :boolean, :aliases => "-r", :default => false, :desc => 'Override the config.rb file and force relative urls'
    class_option :glob, :type => :string, :aliases => "-g", :default => nil, :desc => 'Build a subset of the project'
    
    def initialize(*args)
      super
      
      if options.has_key?("relative") && options["relative"]
        SHARED_SERVER.activate :relative_assets
      end
    end
    
    def source_paths
      @source_paths ||= [
        SHARED_SERVER.root
      ]
    end
    
    def build_all_files
      self.class.shared_rack
      
      if options.has_key?("glob")
        action GlobAction.new(self, SHARED_SERVER.views, SHARED_SERVER.build_dir, { :force => true, :glob => options["glob"] })
      else      
        action DirectoryAction.new(self, SHARED_SERVER.views, SHARED_SERVER.build_dir, { :force => true })
      
        SHARED_SERVER.proxied_paths.each do |url, proxy|
          tilt_template(url.gsub(/^\//, "#{SHARED_SERVER.build_dir}/"), { :force => true })
        end
      end
    end
    
    @@hooks = {}
    def self.after_run(name, &block)
      @@hooks[name] = block
    end
    
    def run_hooks
      return if options.has_key?("glob")
      
      @@hooks.each do |name, proc|
        instance_eval(&proc)
      end
      
      SHARED_SERVER.after_build_callbacks.each do |proc|
        instance_eval(&proc)
      end
    end
  end
  
  class BaseAction < ::Thor::Actions::EmptyDirectory
    attr_reader :source

    def initialize(base, source, destination=nil, config={}, &block)
      @source = File.expand_path(base.find_in_source_paths(source.to_s))
      @block  = block
      super(base, destination, { :recursive => true }.merge(config))
    end

    def invoke!
      base.clean! destination
      execute!
    end

    def revoke!
      execute!
    end
    
  protected
    def handle_path(file_source)
      # Skip partials prefixed with an underscore while still handling files prefixed with 2 consecutive underscores
      return unless file_source.gsub(SHARED_SERVER.root, '').split('/').select { |p| p[/^_[^_]/] }.empty?
      
      file_extension = File.extname(file_source)
      file_destination = File.join(given_destination, file_source.gsub(source, '.'))
      file_destination.gsub!('/./', '/')
      
      handled_by_tilt = ::Tilt.mappings.has_key?(file_extension.gsub(/^\./, ""))
      if handled_by_tilt
        file_destination.gsub!(file_extension, "")
      end
      
      destination = base.tilt_template(file_source, file_destination, config, &@block)
    end
  end
  
  class GlobAction < BaseAction

  protected
    def execute!
      Dir[File.join(source, @config[:glob])].each do |path|
        file_name = path.gsub(SHARED_SERVER.views + "/", "")
        if file_name == "layouts"
          false
        elsif file_name.include?("layout.") && file_name.split(".").length == 2
          false
        else
          next if File.directory?(path)

          handle_path(path)

          true
        end
      end
    end
  end
  
  class DirectoryAction < BaseAction
    def invoke!
      base.empty_directory given_destination, config
      super
    end
    
  protected
    def handle_directory(lookup, &block)
      lookup = File.join(lookup, '*')
      
      results = Dir[lookup].sort do |a, b|
        simple_a = a.gsub(SHARED_SERVER.root + "/", '').gsub(SHARED_SERVER.views + "/", '') 
        simple_b = b.gsub(SHARED_SERVER.root + "/", '').gsub(SHARED_SERVER.views + "/", '')
        
        a_dir = simple_a.split("/").first
        b_dir = simple_b.split("/").first
        
        if a_dir == SHARED_SERVER.images_dir
          -1
        elsif b_dir == SHARED_SERVER.images_dir
          1
        else
          0
        end
      end
      
      results = results.select(&block) if block_given?
      
      results.each do |file_source|
        if File.directory?(file_source)
          handle_directory(file_source)
          next
        end
        
        handle_path(file_source)
      end
    end

    def execute!
      handle_directory(source) do |path|
        file_name = path.gsub(SHARED_SERVER.views + "/", "")
        if file_name == "layouts"
          false
        elsif file_name.include?("layout.") && file_name.split(".").length == 2
          false
        else
          true
        end
      end
    end
    
  end
end