require 'fileutils'
require 'pathname'
require 'compass/commands/base'
require 'compass/commands/update_project'

module Compass
  module Commands
    module WatchProjectOptionsParser
      def set_options(opts)
        super

        opts.banner = %Q{
          Usage: compass watch [path/to/project] [path/to/project/src/file.sass ...] [options]

          Description:
          watch the project for changes and recompile when they occur.

          Options:
        }.split("\n").map{|l| l.gsub(/^ */,'')}.join("\n")

        opts.on("--poll", :NONE, "Check periodically if there's been changes.") do
          self.options[:poll] = 1 # check every 1 second.
        end

      end
    end
    class WatchProject < UpdateProject

      register :watch

      attr_accessor :last_update_time, :last_sass_files

      def perform
        Signal.trap("INT") do
          puts ""
          exit 0
        end

        recompile

        begin
          require 'fssm'
        rescue LoadError
          $: << File.join(Compass.lib_directory, 'vendor', 'fssm')
          retry
        end

        if options[:poll]
          require "fssm/backends/polling"
          # have to silence the ruby warning about chaning a constant.
          stderr, $stderr = $stderr, StringIO.new
          FSSM::Backends.const_set("Default", FSSM::Backends::Polling)
          $stderr = stderr
        end

        action = FSSM::Backends::Default.to_s == "FSSM::Backends::Polling" ? "polling" : "watching"

        puts ">>> Compass is #{action} for changes. Press Ctrl-C to Stop."

        FSSM.monitor do |monitor|
          Compass.configuration.sass_load_paths.each do |load_path|
            monitor.path load_path do |path|
              path.glob '**/*.s[ac]ss'

              path.update &method(:recompile)
              path.delete {|base, relative| remove_obsolete_css(base,relative); recompile(base, relative)}
              path.create &method(:recompile)
            end
          end

        end
        
      end

      def remove_obsolete_css(base = nil, relative = nil)
        compiler = new_compiler_instance(:quiet => true)
        sass_files = compiler.sass_files
        deleted_sass_files = (last_sass_files || []) - sass_files
        deleted_sass_files.each do |deleted_sass_file|
          css_file = compiler.corresponding_css_file(deleted_sass_file)
          remove(css_file) if File.exists?(css_file)
        end
        self.last_sass_files = sass_files
      end

      def recompile(base = nil, relative = nil)
        compiler = new_compiler_instance(:quiet => true)
        if file = compiler.out_of_date?
          begin
            puts ">>> Change detected to: #{file}"
            compiler.run
          rescue StandardError => e
            ::Compass::Exec::Helpers.report_error(e, options)
          end
        end
      end

      class << self
        def option_parser(arguments)
          parser = Compass::Exec::CommandOptionParser.new(arguments)
          parser.extend(Compass::Exec::GlobalOptionsParser)
          parser.extend(Compass::Exec::ProjectOptionsParser)
          parser.extend(CompileProjectOptionsParser)
          parser.extend(WatchProjectOptionsParser)
        end
      end
    end
  end
end
