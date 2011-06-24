require 'middleman/server'
require "thor"
require "thor/group"
require 'rack/test'

module Middleman  
  module ThorActions
    def tilt_template(source, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      destination = args.first || source
      
      source  = File.expand_path(find_in_source_paths(source.to_s))
      context = instance_eval('binding')

      @@rack_test ||= ::Rack::Test::Session.new(::Rack::MockSession.new(Middleman::Server))

      create_file destination, nil, config do
        # The default render just requests the page over Rack and writes the response
        request_path = destination.sub(/^#{Middleman::Server.build_dir}/, "")
        @@rack_test.get(request_path)
        @@rack_test.last_response.body
      end
    end
  end
  
  class Builder < Thor::Group
    include Thor::Actions
    include Middleman::ThorActions
    
    class_option :relative, :type => :boolean, :aliases => "-r", :default => false, :desc => 'Override the config.rb file and force relative urls'
    
    def initialize(*args)
      super
      
      Middleman::Server.new
      
      if options.has_key?("relative") && options["relative"]
        Middleman::Server.activate :relative_assets
      end
    end
    
    
    def source_paths
      @source_paths ||= [
        Middleman::Server.root
      ]
    end
    
    def build_all_files
      action Directory.new(self, Middleman::Server.views, Middleman::Server.build_dir, { :force => true })
    end
    
    @@hooks = {}
    def self.after_run(name, &block)
      @@hooks[name] = block
    end
    
    def run_hooks
      @@hooks.each do |name, proc|
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
    def handle_directory(lookup)
      lookup = File.join(lookup, '*')
      
      results = Dir[lookup].sort do |a, b|
        simple_a = a.gsub(Middleman::Server.root + "/", '')
                    .gsub(Middleman::Server.views + "/", '') 
        simple_b = b.gsub(Middleman::Server.root + "/", '')
                    .gsub(Middleman::Server.views + "/", '')
        
        a_dir = simple_a.split("/").first
        b_dir = simple_b.split("/").first
        
        if a_dir == Middleman::Server.images_dir
          -1
        elsif b_dir == Middleman::Server.images_dir
          1
        else
          0
        end
      end
      
      results.each do |file_source|
        if File.directory?(file_source)
          handle_directory(file_source)
          next
        end
        
        next if file_source.include?('layout')
        
        # Skip partials prefixed with an underscore
        next unless file_source.gsub(Middleman::Server.root, '').split('/').select { |p| p[0,1] == '_' }.empty?
        
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
      handle_directory(source)
    end
  end
end