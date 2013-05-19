require 'thor'

module Padrino
  module Cli

    class Base < Thor
      include Thor::Actions

      class_option :chdir, :type => :string, :aliases => "-c", :desc => "Change to dir before starting"
      class_option :environment, :type => :string,  :aliases => "-e", :required => true, :default => :development, :desc => "Padrino Environment"
      class_option :help, :type => :boolean, :desc => "Show help usage"

      desc "start", "Starts the Padrino application"
      method_option :server,      :type => :string,  :aliases => "-a", :desc => "Rack Handler (default: autodetect)"
      method_option :host,        :type => :string,  :aliases => "-h", :required => true, :default => "0.0.0.0", :desc => "Bind to HOST address"
      method_option :port,        :type => :numeric, :aliases => "-p", :required => true, :default => 3000, :desc => "Use PORT"
      method_option :daemonize,   :type => :boolean, :aliases => "-d", :desc => "Run daemonized in the background"
      method_option :pid,         :type => :string,  :aliases => "-i", :desc => "File to store pid"
      method_option :debug,       :type => :boolean,                   :desc => "Set debugging flags"
      def start
        prepare :start
        require File.expand_path("../adapter", __FILE__)
        require File.expand_path('config/boot.rb')
        Padrino::Cli::Adapter.start(options)
      end

      desc "s", "Starts the Padrino application"
      def s
        invoke :start
      end

      desc "stop", "Stops the Padrino application"
      method_option :pid, :type => :string,  :aliases => "-p", :desc => "File to store pid", :default => 'tmp/pids/server.pid'
      def stop
        prepare :stop
        require File.expand_path("../adapter", __FILE__)
        Padrino::Cli::Adapter.stop(options)
      end

      desc "rake", "Execute rake tasks"
      method_option :environment, :type => :string,  :aliases => "-e", :required => true, :default => :development
      method_option :list,        :type => :string,  :aliases => "-T", :desc => "Display the tasks (matching optional PATTERN) with descriptions, then exit."
      method_option :trace,       :type => :boolean, :aliases => "-t", :desc => "Turn on invoke/execute tracing, enable full backtrace."
      def rake(*args)
        prepare :rake
        args << "-T" if options[:list]
        args << options[:list]  unless options[:list].nil? || options[:list].to_s == "list"
        args << "--trace" if options[:trace]
        args << "--verbose" if options[:verbose]
        ARGV.clear
        ARGV.concat(args)
        puts "=> Executing Rake #{ARGV.join(' ')} ..."
        load File.expand_path('../rake.rb', __FILE__)
        require File.expand_path('config/boot.rb')
        PadrinoTasks.init(true)
      end

      desc "console", "Boots up the Padrino application irb console"
      def console
        prepare :console
        require File.expand_path("../../version", __FILE__)
        ARGV.clear
        require 'irb'
        require "irb/completion"
        require File.expand_path('config/boot.rb')
        puts "=> Loading #{Padrino.env} console (Padrino v.#{Padrino.version})"
        require File.expand_path('../console', __FILE__)
        IRB.start
      end

      desc "c", "Boots up the Padrino application irb console"
      def c(*args)
        invoke(:console, args)
      end

      desc "generate", "Executes the Padrino generator with given options."
      def generate(*args)
        # Build Padrino g as an alias of padrino-gen
        begin
          # We try to load the vendored padrino-gen if exist
          padrino_gen_path = File.expand_path('../../../../../padrino-gen/lib', __FILE__)
          $:.unshift(padrino_gen_path) if File.directory?(padrino_gen_path) && !$:.include?(padrino_gen_path)
          require 'padrino-core/command'
          require 'padrino-gen/command'
          ARGV.shift
          ARGV << 'help' if ARGV.empty?
          Padrino.bin_gen(*ARGV)
        rescue
          puts "<= You need padrino-gen! Run: gem install padrino-gen"
        end
      end

      desc "g", "Executes the Padrino generator with given options."
      def g(*args)
        invoke(:generate, args)
      end

      desc "gen", "Executes the Padrino generator with given options."
      def gen(*args)
        invoke(:generate, args)
      end

      desc "version", "Show current Padrino Version"
      map "-v" => :version, "--version" => :version
      def version
        require 'padrino-core/version'
        puts "Padrino v. #{Padrino.version}"
      end

      private
        def prepare(task)
          if options.help?
            help(task.to_s)
            raise SystemExit
          end
          ENV["PADRINO_ENV"] ||= ENV["RACK_ENV"] ||= options.environment.to_s
          chdir(options.chdir)
          unless File.exist?('config/boot.rb')
            puts "=> Could not find boot file in: #{options.chdir}/config/boot.rb !!!"
            raise SystemExit
          end
        end

      protected
        def self.banner(task=nil, *args)
          "padrino #{task.name}"
        end

        def chdir(dir)
          return unless dir
          begin
            Dir.chdir(dir.to_s)
          rescue Errno::ENOENT
            puts "=> Specified Padrino root '#{dir}' does not appear to exist!"
          rescue Errno::EACCES
            puts "=> Specified Padrino root '#{dir}' cannot be accessed by the current user!"
          end
        end

        def capture(stream)
          begin
            stream = stream.to_s
            eval "$#{stream} = StringIO.new"
            yield
            result = eval("$#{stream}").string
          ensure
            eval("$#{stream} = #{stream.upcase}")
          end

          result
        end
        alias :silence :capture
    end # Base
  end # Cli
end # Padrino
