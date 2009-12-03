require 'compass/commands/project_base'
require 'compass/commands/update_project'

module Compass
  module Commands
    module StatsOptionsParser
      def set_options(opts)
        opts.banner = %Q{
          Usage: compass stats [path/to/project] [options]

          Description:
            Compile project at the path specified (or the current
            directory if not specified) and then compute statistics
            for the sass and css files in the project.

          Options:
        }.strip.split("\n").map{|l| l.gsub(/^ {0,10}/,'')}.join("\n")

        super
      end
    end
    class ProjectStats < UpdateProject

      register :stats

      def initialize(working_path, options)
        super
        assert_project_directory_exists!
      end

      def perform
        super
        require 'compass/stats'
        compiler = new_compiler_instance
        sass_files = sorted_sass_files(compiler)
        rows       = [[           :-,           :-,           :-,            :-,            :-,            :-,               :- ],
                      [   'Filename',      'Rules', 'Properties', 'Mixins Defs', 'Mixins Used',   'CSS Rules', 'CSS Properties' ],
                      [           :-,           :-,           :-,            :-,            :-,            :-,               :- ]]
        maximums   =  [            8,            5,           10,            14,            11,             9,               14 ]
        alignments =  [        :left,       :right,       :right,        :right,        :right,        :right,           :right ]
        delimiters =  [ ['| ', ' |'],  [' ', ' |'],  [' ', ' |'],   [' ', ' |'],   [' ', ' |'],   [' ', ' |'],      [' ', ' |'] ]
        totals     =  [ "Total (#{sass_files.size} files):", 0, 0,            0,             0,             0,                0 ]

        sass_files.each do |sass_file|
          css_file = compiler.corresponding_css_file(sass_file) unless sass_file[0..0] == '_'
          row = filename_columns(sass_file)
          row += sass_columns(sass_file)
          row += css_columns(css_file)
          row.each_with_index do |c, i|
            maximums[i] = [maximums[i].to_i, c.size].max
            totals[i] = totals[i] + c.to_i if i > 0
          end
          rows << row
        end
        rows << [:-] * 7
        rows << totals.map{|t| t.to_s}
        rows << [:-] * 7
        rows.each do |row|
          row.each_with_index do |col, i|
            print pad(col, maximums[i], :align => alignments[i], :left => delimiters[i].first, :right => delimiters[i].last)
          end
          print "\n"
        end
        if @missing_css_parser
          puts "\nInstall css_parser to enable stats on your css files:\n\n\tgem install css_parser"
        end
      end

      def pad(c, max, options = {})
        options[:align] ||= :left
        if c == :-
          filler = '-'
          c = ''
        else
          filler = ' '
        end
        spaces = max - c.size
        filled = filler * [spaces,0].max
        "#{options[:left]}#{filled if options[:align] == :right}#{c}#{filled if options[:align] == :left}#{options[:right]}"
      end

      def sorted_sass_files(compiler)
        sass_files = compiler.sass_files(:exclude_partials => false)
        sass_files.map! do |s| 
          filename = Compass.deprojectize(s, File.join(Compass.configuration.project_path, Compass.configuration.sass_dir))
          [s, File.dirname(filename), File.basename(filename)]
        end
        sass_files = sass_files.sort_by do |s,d,f|
          File.join(d, f[0] == ?_ ? f[1..-1] : f)
        end
        sass_files.map!{|s,d,f| s}
      end

      def filename_columns(sass_file)
        filename = Compass.deprojectize(sass_file, working_path)
        [filename]
      end

      def sass_columns(sass_file)
        sf = Compass::Stats::SassFile.new(sass_file)
        sf.analyze!
        %w(rule_count prop_count mixin_def_count mixin_count).map do |t|
          sf.send(t).to_s
        end
      end

      def css_columns(css_file)
        if File.exists?(css_file)
          cf = Compass::Stats::CssFile.new(css_file)
          cf.analyze!
          %w(selector_count prop_count).map do |t|
            cf.send(t).to_s
          end
        else
          return [ '--', '--' ]
        end
      rescue LoadError
        @missing_css_parser = true
        return [ 'DISABLED', 'DISABLED' ]
      end

      class << self

        def option_parser(arguments)
          parser = Compass::Exec::CommandOptionParser.new(arguments)
          parser.extend(Compass::Exec::GlobalOptionsParser)
          parser.extend(Compass::Exec::ProjectOptionsParser)
          parser.extend(StatsOptionsParser)
        end

        def usage
          option_parser([]).to_s
        end

        def description(command)
          "Report statistics about your stylesheets"
        end

        def primary; false; end

        def parse!(arguments)
          parser = option_parser(arguments)
          parser.parse!
          parse_arguments!(parser, arguments)
          parser.options
        end

        def parse_arguments!(parser, arguments)
          if arguments.size == 1
            parser.options[:project_name] = arguments.shift
          elsif arguments.size == 0
            # default to the current directory.
          else
            raise Compass::Error, "Too many arguments were specified."
          end
        end

      end

    end
  end
end
