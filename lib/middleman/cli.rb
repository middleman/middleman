require 'thor'

module Middleman
  class CLI < Thor
    include Thor::Actions
    check_unknown_options!
    default_task :server

    class_option "help", 
      :type    => :boolean, 
      :default => false, 
      :aliases => "-h"
    def initialize(*)
      super
      help_check if options[:help]
    end

    desc "init NAME [options]", "Create new project NAME"
    available_templates = Middleman::Templates.registered.keys.join(", ")
    method_option "template", 
      :aliases => "-T", 
      :default => "default",
      :desc    => "Use a project template: #{available_templates}"
    method_option "css_dir", 
      :default => "stylesheets", 
      :desc    => 'The path to the css files'
    method_option "js_dir", 
      :default => "javascripts", 
      :desc    => 'The path to the javascript files'
    method_option "images_dir", 
      :default => "images", 
      :desc    => 'The path to the image files'
    method_option "rack", 
      :type    => :boolean, 
      :default => false, 
      :desc    => 'Include a config.ru file'
    method_option "bundler", 
      :type    => :boolean, 
      :default => false, 
      :desc    => 'Create a Gemfile and use Bundler to manage gems'
    def init(name)
      key = options[:template].to_sym
      unless Middleman::Templates.registered.has_key?(key)
        raise Thor::Error.new "Unknown project template '#{key}'"
      end
      
      thor_group = Middleman::Templates.registered[key]
      thor_group.new([name], options).invoke_all
    end

    desc "server [options]", "Start the preview server"
    method_option "environment", 
      :aliases => "-e", 
      :default => ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development', 
      :desc    => "The environment Middleman will run under"
      method_option :host,
        :type => :string,
        :aliases => "-h",
        # :required => true,
        :default => "0.0.0.0", 
        :desc => "Bind to HOST address"
    method_option "port",
      :aliases => "-p", 
      :default => "4567", 
      :desc    => "The port Middleman will listen on"
    method_option "debug", 
      :type    => :boolean, 
      :default => false,
      :desc    => 'Print debug messages'
    def server
      params = {
        :port        => options["port"],
        :host        => options["host"],
        :environment => options["environment"],
        :debug       => options["debug"]
      }
      
      puts "== The Middleman is loading"
      Middleman::Guard.start(params)
    end

    desc "build", "Builds the static site for deployment"
    method_option :relative, 
      :type    => :boolean, 
      :aliases => "-r", 
      :default => false, 
      :desc    => 'Force relative urls'
    method_option :clean, 
      :type    => :boolean, 
      :aliases => "-c", 
      :default => false, 
      :desc    => 'Removes orpahand files or directories from build'
    method_option :glob, 
      :type    => :string, 
      :aliases => "-g", 
      :default => nil, 
      :desc    => 'Build a subset of the project'
    def build
      thor_group = Middleman::Builder.new([], options).invoke_all
    end

    desc "migrate", "Migrates an older project to the 2.0 structure"
    def migrate
      return if File.exists?("source")
      `mv public source`
      `cp -R views/* source/`
      `rm -rf views`
    end

    desc "version", "Show version"
    def version
      require 'middleman/version'
      say "Middleman #{Middleman::VERSION}"
    end
    
  private

    def help_check
      help self.class.send(:retrieve_task_name, ARGV.dup)
      exit 0
    end
  end
end
