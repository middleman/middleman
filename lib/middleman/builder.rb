require 'middleman/server'
require 'templater'
require 'middleman/templater+dynamic_renderer.rb'

# Placeholder for any methods the builder needs to abstract to allow feature integration
module Middleman
  class Builder < ::Templater::Generator
    
    # Support all Tilt-enabled templates and treat js like a template
    @@template_extensions = ::Tilt.mappings.keys << "js"
    
    # Define source and desintation
    def self.source_root; Dir.pwd; end
    def destination_root; File.join(Dir.pwd, Middleman::Server.build_dir); end

    # Override template to ask middleman for the correct extension to output
    def self.template(name, *args, &block)
      return if args[0].include?('layout')

      args.first.split('/').each do |part|
        return if part[0,1] == '_'
      end

      if (args[0] === args[1])
        args[1] = args[0].gsub("#{File.basename(Middleman::Server.views)}/", "").gsub("#{File.basename(Middleman::Server.public)}/", "")
        if File.extname(args[1]) != ".js"
          args[1] = args[1].gsub!(File.extname(args[1]), "") if File.basename(args[1]).split('.').length > 2
        end
      end

      super(name, *args, &block)
    end

    def self.file(name, *args, &block)
      file_ext = File.extname(args[0])
      
      return unless ::Tilt[file_ext].nil?
      
      if (args[0] === args[1])
        args[1] = args[0].gsub("#{File.basename(Middleman::Server.views)}/", "").gsub("#{File.basename(Middleman::Server.public)}/", "")
      end
      super(name, *args, &block)
    end

    def self.init!
      glob! File.basename(Middleman::Server.public),  @@template_extensions
      glob! File.basename(Middleman::Server.views),   @@template_extensions
    end
    
    def after_run
    end
  end
  
  module Generators
    extend ::Templater::Manifold
    desc "Build a static site"

    add :build, ::Middleman::Builder
  end
end