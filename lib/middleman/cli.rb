require 'thor'
require 'middleman'
require "middleman/templates"

module Middleman
  class CLI < Thor
    include Thor::Actions
    default_task :server

    def initialize(*)
      config_check
      super
    end

    desc "init NAME", "Create new Middleman project directory NAME"
    available_templates = Middleman::Templates.registered_names.join(", ")
    method_option :template, :aliases => "-T", :default => "default", :desc => "Optionally use a pre-defined project template: #{available_templates}"
    method_option :css_dir, :default => "stylesheets", :desc => 'The path to the css files'
    method_option :js_dir, :default => "javascripts", :desc => 'The path to the javascript files'
    method_option :images_dir, :default => "images", :desc => 'The path to the image files'
    def init(name)
      key = options[:template].to_sym
      key = :default unless Middleman::Templates.registered_templates.has_key?(key)

      Middleman::Templates.registered_templates[key].start
    end

    desc "server [-p 4567] [-e development]", "Starts the Middleman preview server"
    method_option "environment", :aliases => "-e", :default => ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development', :desc => "The environment Middleman will run under"
    method_option "port", :aliases => "-p", :default => "4567", :desc => "The port Middleman will listen on"
    method_option "livereload-port", :default => "35729", :desc => "The port Livereload will listen on"
    method_option "livereload", :default => false, :type => :boolean, :desc => "Whether to enable Livereload or not"
    def server
      ENV['RACK_ENV'] = options[:environment]
      livereload_options = {:port => options["livereload-port"]} if options["livereload"]
      Middleman::Guard.start({:port => options[:port]}, livereload_options)
    end

    desc "build", "Builds the static site for deployment"
    method_option :relative, :type => :boolean, :aliases => "-r", :default => false, :desc => 'Override the config.rb file and force relative urls'
    def build
      ENV['MM_ENV'] = "build"
      Middleman::Builder.start
    end

    desc "migrate", "Migrates an older Middleman project to the 2.0 structure"
    def migrate
      `mv public source`
      `cp -R views/* source/`
      `rm -rf views`
    end

  private

    def config_check
      if !File.exists?("config.rb")
        $stderr.puts "== Error: Could not find a Middleman project config, perhaps you are in the wrong folder?"
        exit 1
      end

      if File.exists?("views") || File.exists?("public")
        $stderr.puts "== Error: The views and public folders are have been combined. Create a new 'source' folder, add the contents of views and public to it and then remove the empty views and public folders."
        exit 1
      end
    end

  end
end