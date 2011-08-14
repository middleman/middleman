require "thor"
require "thor/group"
require 'rack/test'

SHARED_SERVER = Middleman.server
SHARED_SERVER.set :environment, :build

module Middleman  
  module ThorActions
    def tilt_template(source, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      destination = args.first || source
      
      # source  = File.expand_path(find_in_source_paths(source.to_s))
      context = instance_eval('binding')
      
      request_path = destination.sub(/^#{SHARED_SERVER.build_dir}/, "")
      
      begin        
        destination, request_page = SHARED_SERVER.reroute_builder(destination, request_path)
      
        create_file destination, nil, config do
          Middleman::Builder.shared_rack.get(request_path.gsub(/\s/, "%20"))
          Middleman::Builder.shared_rack.last_response.body
        end
      rescue
      end
    end
  end
  
  class Builder < Thor::Group
    include Thor::Actions
    include Middleman::ThorActions
    
    def self.shared_rack
      @shared_rack ||= begin  
        mock = ::Rack::MockSession.new(SHARED_SERVER)
        sess = ::Rack::Test::Session.new(mock)
        sess.get("/")
        sess
      end
    end
    
    class_option :relative, :type => :boolean, :aliases => "-r", :default => false, :desc => 'Override the config.rb file and force relative urls'
    
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
      
      action Directory.new(self, SHARED_SERVER.views, SHARED_SERVER.build_dir, { :force => true })
      
      SHARED_SERVER.proxied_paths.each do |url, proxy|
        tilt_template(url.gsub(/^\//, "#{SHARED_SERVER.build_dir}/"), { :force => true })
      end
    end
    
    @@hooks = {}
    def self.after_run(name, &block)
      @@hooks[name] = block
    end
    
    def run_hooks
      @@hooks.each do |name, proc|
        instance_eval(&proc)
      end
      
      SHARED_SERVER.after_build_callbacks.each do |proc|
        instance_eval(&proc)
      end
    end
  end
  
  class Directory < ::Thor::Actions::EmptyDirectory
    attr_reader :source

    def initialize(base, source, destination=nil, config={}, &block)
      @source = File.expand_path(base.find_in_source_paths(source.to_s))
      @block  = block
      super(base, destination, { :recursive => true }.merge(config))
    end

    def invoke!
      base.empty_directory given_destination, config
      execute!
    end

    def revoke!
      execute!
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
        
        # Skip partials prefixed with an underscore
        next unless file_source.gsub(SHARED_SERVER.root, '').split('/').select { |p| p[0,1] == '_' }.empty?
        
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