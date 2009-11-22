require 'fileutils'
require 'pathname'
require File.join(File.dirname(__FILE__), 'base')
require File.join(File.dirname(__FILE__), 'update_project')

module Compass
  module Commands
    class WatchProject < UpdateProject

      attr_accessor :last_update_time, :last_sass_files

      def perform
        Signal.trap("INT") do
          puts ""
          exit 0
        end

        recompile

        puts ">>> Compass is watching for changes. Press Ctrl-C to Stop."

        require File.join(Compass.lib_directory, 'vendor', 'fssm')

        FSSM.monitor do |monitor|
          Compass.configuration.sass_load_paths.each do |load_path|
            monitor.path load_path do |path|
              path.glob '**/*.sass'

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
            ::Compass::Exec.report_error(e, options)
          end
        end
      end

    end
  end
end