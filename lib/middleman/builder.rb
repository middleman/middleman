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
        request_path = destination.gsub(Middleman::Server.build_dir, "")
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
      [
        Middleman::Server.public,
        Middleman::Server.views
      ]
    end
    
    def build_static_files
      action Directory.new(self, Middleman::Server.public, Middleman::Server.build_dir, { :force => true })
    end
    
    def build_dynamic_files
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
      lookup = File.join(lookup, '{*,.[a-z]*}')
      
      Dir[lookup].sort.each do |file_source|
        if File.directory?(file_source)
          handle_directory(file_source)
          next
        end
        
        next if file_source.include?('layout')
        next unless file_source.split('/').select { |p| p[0,1] == '_' }.empty?
      
        file_extension = File.extname(file_source)
        file_destination = File.join(given_destination, file_source.gsub(source, '.'))
        file_destination.gsub!('/./', '/')
      
        handled_by_tilt = ::Tilt.mappings.keys.include?(file_extension.gsub(/^\./, ""))
        if handled_by_tilt || (file_extension == ".js")
          new_file_extension = (file_extension == ".js") ? ".js" : ""
          next if file_source.split('/').last.split('.').length < 3
        
          file_destination.gsub!(file_extension, new_file_extension)
          destination = base.tilt_template(file_source, file_destination, config, &@block)
        else  
          destination = base.copy_file(file_source, file_destination, config, &@block)
        end
      end
    end

    def execute!
      handle_directory(source)
    end
  end
end