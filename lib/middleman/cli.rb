require 'thor'

module Middleman
  class CLI < Thor
    include Thor::Actions
    check_unknown_options!
    default_task :server

    class_option "help", :type => :boolean, :default => false, :aliases => "-h"
    def initialize(*)
      super
      help_check if options[:help]
    end

    desc "init NAME", "Create new Middleman project directory NAME"
    available_templates = Middleman::Templates.registered_names.join(", ")
    method_option "template", :aliases => "-T", :default => "default", :desc => "Optionally use a pre-defined project template: #{available_templates}"
    method_option "css_dir", :default => "stylesheets", :desc => 'The path to the css files'
    method_option "js_dir", :default => "javascripts", :desc => 'The path to the javascript files'
    method_option "images_dir", :default => "images", :desc => 'The path to the image files'
    method_option "rack", :type => :boolean, :default => false, :desc => 'Include a config.ru file'
    method_option "bundler", :type => :boolean, :default => false, :desc => 'Create a Gemfile and use Bundler to manage gems'
    def init(name)
      key = options[:template].to_sym
      unless Middleman::Templates.registered_templates.has_key?(key)
        key = :default
      end
      
      thor_group = Middleman::Templates.registered_templates[key]
      thor_group.new([name], options).invoke_all
    end

    desc "server [-p 4567] [-e development]", "Starts the Middleman preview server"
    method_option "environment", :aliases => "-e", :default => ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development', :desc => "The environment Middleman will run under"
    method_option "port", :aliases => "-p", :default => "4567", :desc => "The port Middleman will listen on"
    method_option "livereload", :default => false, :type => :boolean, :desc => "Whether to enable Livereload or not"
    method_option "livereload-port", :default => "35729", :desc => "The port Livereload will listen on"
    def server
      v1_check
      
      if options["livereload"]
        livereload_options = {:port => options["livereload-port"]}
      end
    
      Middleman::Guard.start({
        :port        => options[:port],
        :environment => options[:environment]
      }, livereload_options)
    end

    desc "build", "Builds the static site for deployment"
    method_option "relative", :type => :boolean, :aliases => "-r", :default => false, :desc => 'Override the config.rb file and force relative urls'
    def build
      v1_check
      thor_group = Middleman::Builder.new([], options).invoke_all
    end

    desc "migrate", "Migrates an older Middleman project to the 2.0 structure"
    def migrate
      return if File.exists?("source")
      `mv public source`
      `cp -R views/* source/`
      `rm -rf views`
    end

    desc "version", "Show Middleman version"
    def version
      require 'middleman/version'
      say "Middleman #{Middleman::VERSION}"
    end
    
  private
    
    def v1_check
      if File.exists?("views") || File.exists?("public")
        $stderr.puts "== Error: The views and public folders are have been combined. Use the 'middleman migrate' command to merge your folders automatically."
        exit 1
      end
    end

    def help_check
      help self.class.send(:retrieve_task_name, ARGV.dup)
      exit 0
    end

  end
end