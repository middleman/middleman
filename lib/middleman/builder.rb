require 'templater'
require 'middleman/templater+dynamic_renderer.rb'
require 'rack/test' # Use Rack::Test to access Sinatra without starting up a full server

# Placeholder for any methods the builder needs to abstract to allow feature integration
module Middleman
  class Builder < ::Templater::Generator
    # Define source and desintation
    def self.source_root; Dir.pwd; end
    def destination_root; File.join(Dir.pwd, Middleman::Base.build_dir); end

    # Override template to ask middleman for the correct extension to output
    def self.template(name, *args, &block)
      return if args[0].include?('layout')

      args.first.split('/').each do |part|
        return if part[0,1] == '_'
      end

      if (args[0] === args[1])
        args[1] = args[0].gsub("#{File.basename(Middleman::Base.views)}/", "")
                         .gsub("#{File.basename(Middleman::Base.public)}/", "")
        if File.extname(args[1]) != ".js"
          args[1] = args[1].gsub!(File.extname(args[1]), "") if File.basename(args[1]).split('.').length > 2
        end
      end

      super(name, *args, &block)
    end

    def self.file(name, *args, &block)
      if (args[0] === args[1])
        args[1] = args[0].gsub("#{File.basename(Middleman::Base.views)}/", "")
                         .gsub("#{File.basename(Middleman::Base.public)}/", "")
      end
      super(name, *args, &block)
    end

    def self.init!
      glob! File.basename(Middleman::Base.public), Middleman::Base.supported_formats
      glob! File.basename(Middleman::Base.views),  Middleman::Base.supported_formats
    end
  end
  
  module Generators
    extend ::Templater::Manifold
    desc "Build a static site"

    add :build, ::Middleman::Builder
  end
end