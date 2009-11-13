require 'cucumber/cli/profile_loader'
module Cucumber
  module Cli

    class Options
      BUILTIN_FORMATS = {
        'html'      => ['Cucumber::Formatter::Html',     'Generates a nice looking HTML report.'],
        'pretty'    => ['Cucumber::Formatter::Pretty',   'Prints the feature as is - in colours.'],
        'pdf'       => ['Cucumber::Formatter::Pdf',      "Generates a PDF report. You need to have the\n" +
                                                         "#{' ' * 51}prawn gem installed. Will pick up logo from\n" +
                                                         "#{' ' * 51}features/support/logo.png or\n" +
                                                         "#{' ' * 51}features/support/logo.jpg if present."],
        'progress'  => ['Cucumber::Formatter::Progress', 'Prints one character per scenario.'],
        'rerun'     => ['Cucumber::Formatter::Rerun',    'Prints failing files with line numbers.'],
        'usage'     => ['Cucumber::Formatter::Usage',    "Prints where step definitions are used.\n" +
                                                         "#{' ' * 51}The slowest step definitions (with duration) are\n" +
                                                         "#{' ' * 51}listed first. If --dry-run is used the duration\n" +
                                                         "#{' ' * 51}is not shown, and step definitions are sorted by\n" +
                                                         "#{' ' * 51}filename instead."],
        'stepdefs'  => ['Cucumber::Formatter::Stepdefs', "Prints All step definitions with their locations. Same as\n" +
                                                         "#{' ' * 51}the usage formatter, except that steps are not printed."],
        'junit'     => ['Cucumber::Formatter::Junit',    'Generates a report similar to Ant+JUnit.'],
        'tag_cloud' => ['Cucumber::Formatter::TagCloud', 'Prints a tag cloud of tag usage.'],
        'debug'     => ['Cucumber::Formatter::Debug',    'For developing formatters - prints the calls made to the listeners.']
      }
      max = BUILTIN_FORMATS.keys.map{|s| s.length}.max
      FORMAT_HELP = (BUILTIN_FORMATS.keys.sort.map do |key|
        "  #{key}#{' ' * (max - key.length)} : #{BUILTIN_FORMATS[key][1]}"
      end) + ["Use --format rerun --out features.txt to write out failing",
        "features. You can rerun them with cucumber @features.txt.",
        "FORMAT can also be the fully qualified class name of",
        "your own custom formatter. If the class isn't loaded,",
        "Cucumber will attempt to require a file with a relative",
        "file name that is the underscore name of the class name.",
        "Example: --format Foo::BarZap -> Cucumber will look for",
        "foo/bar_zap.rb. You can place the file with this relative",
        "path underneath your features/support directory or anywhere",
        "on Ruby's LOAD_PATH, for example in a Ruby gem."
      ]
      DRB_FLAG = '--drb'
      PROFILE_SHORT_FLAG = '-p'
      NO_PROFILE_SHORT_FLAG = '-P'
      PROFILE_LONG_FLAG = '--profile'
      NO_PROFILE_LONG_FLAG = '--no-profile'


      def self.parse(args, out_stream, error_stream, options = {})
        new(out_stream, error_stream, options).parse!(args)
      end

      def initialize(out_stream = STDOUT, error_stream = STDERR, options = {})
        @out_stream   = out_stream
        @error_stream = error_stream

        @default_profile = options[:default_profile]
        @skip_profile_information = options[:skip_profile_information]
        @profiles = []
        @overridden_paths = []
        @options = default_options
        
        @quiet = @disable_profile_loading = nil
      end

      def [](key)
        @options[key]
      end

      def []=(key, value)
        @options[key] = value
      end

      def expanded_args_without_drb
        return @expanded_args_without_drb  if @expanded_args_without_drb
        @expanded_args_without_drb = (
          previous_flag_was_profile = false
          @expanded_args.reject do |arg|
            if previous_flag_was_profile
              previous_flag_was_profile = false
              next true
            end
            if [PROFILE_SHORT_FLAG, PROFILE_LONG_FLAG].include?(arg)
              previous_flag_was_profile = true
              next true
            end
            arg == DRB_FLAG || @overridden_paths.include?(arg)
          end
        )

        @expanded_args_without_drb.push("--no-profile") unless @expanded_args_without_drb.include?(NO_PROFILE_LONG_FLAG) || @expanded_args_without_drb.include?(NO_PROFILE_SHORT_FLAG)
        @expanded_args_without_drb
      end

      def parse!(args)
        @args = args
        @expanded_args = @args.dup

        @args.extend(::OptionParser::Arguable)

        @args.options do |opts|
          opts.banner = ["Usage: cucumber [options] [ [FILE|DIR|URL][:LINE[:LINE]*] ]+", "",
            "Examples:",
            "cucumber examples/i18n/en/features",
            "cucumber @features.txt (See --format rerun)",
            "cucumber --language it examples/i18n/it/features/somma.feature:6:98:113",
            "cucumber -s -i http://rubyurl.com/eeCl", "", "",
          ].join("\n")
          opts.on("-r LIBRARY|DIR", "--require LIBRARY|DIR",
            "Require files before executing the features. If this",
            "option is not specified, all *.rb files that are",
            "siblings or below the features will be loaded auto-",
            "matically. Automatic loading is disabled when this",
            "option is specified, and all loading becomes explicit.",
            "Files under directories named \"support\" are always",
            "loaded first.",
            "This option can be specified multiple times.") do |v|
            @options[:require] << v
          end
          opts.on("-l LANG", "--language LANG",
            "Specify language for features (Default: #{@options[:lang]})",
            %{Run with "--language help" to see all languages},
            %{Run with "--language LANG help" to list keywords for LANG}) do |v|
            if v == 'help'
              list_languages_and_exit
            elsif args==['help'] # I think this conditional is just cruft and can be removed
              list_keywords_and_exit(v)
            else
              @options[:lang] = v
            end
          end
          opts.on("-f FORMAT", "--format FORMAT",
            "How to format features (Default: pretty). Available formats:",
            *FORMAT_HELP) do |v|
            @options[:formats] << [v, @out_stream]
          end
          opts.on("-o", "--out [FILE|DIR]",
            "Write output to a file/directory instead of STDOUT. This option",
            "applies to the previously specified --format, or the",
            "default format if no format is specified. Check the specific",
            "formatter's docs to see whether to pass a file or a dir.") do |v|
            @options[:formats] << ['pretty', nil] if @options[:formats].empty?
            @options[:formats][-1][1] = v
          end
          opts.on("-t TAGS", "--tags TAGS",
            "Only execute the features or scenarios with the specified tags.",
            "TAGS must be comma-separated without spaces. Example: --tags @dev\n",
            "You can select tags using logical AND or logical OR:",
            "To execute anything that is tagged with both @dev AND @prod\n",
            "Example: --tags @dev,@prod",
            "To execute anything that is tagged with @dev OR @prod\n",
            "Example: --tags @dev --tags @prod\n",
            "Negative tags: Prefix tags with ~ to exclude features or scenarios",
            "having that tag. Example: --tags ~@slow\n",
            "Limit WIP: Positive tags can be given a threshold to limit the",
            "number of occurrences. Example: --tags @qa:3 will fail if there",
            "are more than 3 occurrences of the @qa tag.") do |v|
            tag_names = parse_tags(v)
            @options[:tag_names] << tag_names
          end
          opts.on("-n NAME", "--name NAME",
            "Only execute the feature elements which match part of the given name.",
            "If this option is given more than once, it will match against all the",
            "given names.") do |v|
            @options[:name_regexps] << /#{v}/
          end
          opts.on("-e", "--exclude PATTERN", "Don't run feature files or require ruby files matching PATTERN") do |v|
            @options[:excludes] << Regexp.new(v)
          end
          opts.on(PROFILE_SHORT_FLAG, "#{PROFILE_LONG_FLAG} PROFILE",
              "Pull commandline arguments from cucumber.yml which can be defined as",
              "strings or arrays.  When a 'default' profile is defined and no profile",
              "is specified it is always used. (Unless disabled, see -P below.)",
              "When feature files are defined in a profile and on the command line",
              "then only the ones from the command line are used.") do |v|
            @profiles << v
          end
          opts.on(NO_PROFILE_SHORT_FLAG, NO_PROFILE_LONG_FLAG,
            "Disables all profile laoding to avoid using the 'default' profile.") do |v|
            @disable_profile_loading = true
          end
          opts.on("-c", "--[no-]color",
            "Whether or not to use ANSI color in the output. Cucumber decides",
            "based on your platform and the output destination if not specified.") do |v|
            Term::ANSIColor.coloring = v
          end
          opts.on("-d", "--dry-run", "Invokes formatters without executing the steps.",
            "This also omits the loading of your support/env.rb file if it exists.",
            "Implies --no-snippets.") do
            @options[:dry_run] = true
            @options[:snippets] = false
          end
          opts.on("-a", "--autoformat DIRECTORY",
            "Reformats (pretty prints) feature files and write them to DIRECTORY.",
            "Be careful if you choose to overwrite the originals.",
            "Implies --dry-run --formatter pretty.") do |directory|
            @options[:autoformat] = directory
            Term::ANSIColor.coloring = false
            @options[:dry_run] = true
            @quiet = true
          end

          opts.on("-m", "--no-multiline",
            "Don't print multiline strings and tables under steps.") do
            @options[:no_multiline] = true
          end
          opts.on("-s", "--no-source",
            "Don't print the file and line of the step definition with the steps.") do
            @options[:source] = false
          end
          opts.on("-i", "--no-snippets", "Don't print snippets for pending steps.") do
            @options[:snippets] = false
          end
          opts.on("-q", "--quiet", "Alias for --no-snippets --no-source.") do
            @quiet = true
          end
          opts.on("-b", "--backtrace", "Show full backtrace for all errors.") do
            Cucumber.use_full_backtrace = true
          end
          opts.on("-S", "--strict", "Fail if there are any undefined steps.") do
            @options[:strict] = true
          end
          opts.on("-w", "--wip", "Fail if there are any passing scenarios.") do
            @options[:wip] = true
          end
          opts.on("-v", "--verbose", "Show the files and features loaded.") do
            @options[:verbose] = true
          end
          opts.on("-g", "--guess", "Guess best match for Ambiguous steps.") do
            @options[:guess] = true
          end
          opts.on("-x", "--expand", "Expand Scenario Outline Tables in output.") do
            @options[:expand] = true
          end
          opts.on("--no-diff", "Disable diff output on failing expectations.") do
            @options[:diff_enabled] = false
          end
          opts.on(DRB_FLAG, "Run features against a DRb server. (i.e. with the spork gem)") do
            @options[:drb] = true
          end
          opts.on("--port PORT", "Specify DRb port.  Ignored without --drb") do |port|
            @options[:drb_port] = port
          end
          opts.on_tail("--version", "Show version.") do
            @out_stream.puts Cucumber::VERSION
            Kernel.exit(0)
          end
          opts.on_tail("-h", "--help", "You're looking at it.") do
            @out_stream.puts opts.help
            Kernel.exit(0)
          end
        end.parse!

        if @quiet
          @options[:snippets] = @options[:source] = false
        else
          @options[:snippets] = true if @options[:snippets].nil?
          @options[:source]   = true if @options[:source].nil?
        end

        extract_environment_variables
        @options[:paths] = @args.dup #whatver is left over

        merge_profiles
        print_profile_information

        self
      end

    protected

      attr_reader :options, :profiles, :expanded_args
      protected :options, :profiles, :expanded_args

    private

    def non_stdout_formats
      @options[:formats].select {|format, output| output != @out_stream }
    end

    def stdout_formats
      @options[:formats].select {|format, output| output == @out_stream }
    end

     def extract_environment_variables
        @args.delete_if do |arg|
          if arg =~ /^(\w+)=(.*)$/
            @options[:env_vars][$1] = $2
            true
          end
        end
      end

      def parse_tags(tag_string)
        tag_names = Ast::Tags.parse_tags(tag_string)
        parse_tag_limits(tag_names)
      end

      def parse_tag_limits(tag_names)
        tag_names.inject({}) do |dict, tag|
          tag, limit = tag.split(':')
          dict[tag] = limit.nil? ? limit : limit.to_i
          dict
        end
      end

      def disable_profile_loading?
        @disable_profile_loading
      end

      def merge_profiles
        if @disable_profile_loading
          @out_stream.puts "Disabling profiles..."
          return
        end

        @profiles << @default_profile if default_profile_should_be_used?

        @profiles.each do |profile|
          profile_args = profile_loader.args_from(profile)
          reverse_merge(
            Options.parse(profile_args, @out_stream, @error_stream, :skip_profile_information  => true)
          )
        end

      end

      def default_profile_should_be_used?
        @profiles.empty? &&
          profile_loader.cucumber_yml_defined? &&
          profile_loader.has_profile?(@default_profile)
      end

      def profile_loader
        @profile_loader ||= ProfileLoader.new
      end

      def reverse_merge(other_options)
        @options = other_options.options.merge(@options)
        @options[:require] += other_options[:require]
        @options[:excludes] += other_options[:excludes]
        @options[:name_regexps] += other_options[:name_regexps]
        @options[:tag_names] += other_options[:tag_names]
        @options[:env_vars] = other_options[:env_vars].merge(@options[:env_vars])
        if @options[:paths].empty?
          @options[:paths] = other_options[:paths]
        else
          @overridden_paths += (other_options[:paths] - @options[:paths])
        end
        @options[:source] &= other_options[:source]
        @options[:snippets] &= other_options[:snippets]

        @profiles += other_options.profiles
        @expanded_args += other_options.expanded_args

        if @options[:formats].empty?
          @options[:formats] = other_options[:formats]
        else
          @options[:formats] += other_options[:formats]
          @options[:formats] = stdout_formats[0..0] + non_stdout_formats
        end

        self
      end

      # TODO: Move to Language
      def list_keywords_and_exit(lang)
        unless Cucumber::LANGUAGES[lang]
          raise("No language with key #{lang}")
        end
        LanguageHelpFormatter.list_keywords(@out_stream, lang)
        Kernel.exit(0)
      end

      def list_languages_and_exit
        LanguageHelpFormatter.list_languages(@out_stream)
        Kernel.exit(0)
      end

      def print_profile_information
        return if @skip_profile_information || @profiles.empty?
        profiles_sentence = ''
        profiles_sentence = @profiles.size == 1 ? @profiles.first :
          "#{@profiles[0...-1].join(', ')} and #{@profiles.last}"

        @out_stream.puts "Using the #{profiles_sentence} profile#{'s' if @profiles.size> 1}..."
      end

      def default_options
        {
          :strict       => false,
          :require      => [],
          :dry_run      => false,
          :formats      => [],
          :excludes     => [],
          :tag_names    => [],
          :name_regexps => [],
          :env_vars     => {},
          :diff_enabled => true
        }
      end
    end

  end
end
