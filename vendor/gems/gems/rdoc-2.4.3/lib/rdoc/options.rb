require 'optparse'

require 'rdoc/ri/paths'

##
# RDoc::Options handles the parsing and storage of options

class RDoc::Options

  ##
  # Character-set

  attr_reader :charset

  ##
  # Should diagrams be drawn?

  attr_accessor :diagram

  ##
  # Files matching this pattern will be excluded

  attr_accessor :exclude

  ##
  # Should we draw fileboxes in diagrams?

  attr_reader :fileboxes

  ##
  # The list of files to be processed

  attr_accessor :files

  ##
  # Scan newer sources than the flag file if true.

  attr_reader :force_update

  ##
  # Description of the output generator (set with the <tt>-fmt</tt> option)

  attr_accessor :generator

  ##
  # Formatter to mark up text with

  attr_accessor :formatter

  ##
  # Image format for diagrams

  attr_reader :image_format

  ##
  # Include line numbers in the source listings?

  attr_reader :include_line_numbers

  ##
  # Name of the file, class or module to display in the initial index page (if
  # not specified the first file we encounter is used)

  attr_accessor :main_page

  ##
  # Merge into classes of the same name when generating ri

  attr_reader :merge

  ##
  # The name of the output directory

  attr_accessor :op_dir

  ##
  # Is RDoc in pipe mode?

  attr_accessor :pipe

  ##
  # Array of directories to search for files to satisfy an :include:

  attr_reader :rdoc_include

  ##
  # Include private and protected methods in the output?

  attr_accessor :show_all

  ##
  # Include the '#' at the front of hyperlinked instance method names

  attr_reader :show_hash

  ##
  # The number of columns in a tab

  attr_reader :tab_width

  ##
  # Template to be used when generating output

  attr_reader :template

  ##
  # Number of threads to parse with

  attr_accessor :threads

  ##
  # Documentation title

  attr_reader :title

  ##
  # Verbosity, zero means quiet

  attr_accessor :verbosity

  ##
  # URL of web cvs frontend

  attr_reader :webcvs

  def initialize # :nodoc:
    require 'rdoc/rdoc'
    @op_dir = 'doc'
    @show_all = false
    @main_page = nil
    @merge = false
    @exclude = []
    @generators = RDoc::RDoc::GENERATORS
    @generator = RDoc::Generator::Darkfish
    @generator_name = nil
    @rdoc_include = []
    @title = nil
    @template = nil
    @threads = if RUBY_PLATFORM == 'java' then
                 Java::java::lang::Runtime.getRuntime.availableProcessors * 2
               else
                 2
               end
    @diagram = false
    @fileboxes = false
    @show_hash = false
    @image_format = 'png'
    @tab_width = 8
    @include_line_numbers = false
    @force_update = true
    @verbosity = 1
    @pipe = false

    @webcvs = nil

    @charset = 'utf-8'
  end

  ##
  # Parse command line options.

  def parse(argv)
    opts = OptionParser.new do |opt|
      opt.program_name = File.basename $0
      opt.version = RDoc::VERSION
      opt.release = nil
      opt.summary_indent = ' ' * 4
      opt.banner = <<-EOF
Usage: #{opt.program_name} [options] [names...]

  Files are parsed, and the information they contain collected, before any
  output is produced. This allows cross references between all files to be
  resolved. If a name is a directory, it is traversed. If no names are
  specified, all Ruby files in the current directory (and subdirectories) are
  processed.

  How RDoc generates output depends on the output formatter being used, and on
  the options you give.

  - Darkfish creates frameless HTML output by Michael Granger.

  - ri creates ri data files
      EOF

      opt.separator nil
      opt.separator "Parsing Options:"
      opt.separator nil

      opt.on("--all", "-a",
             "Include all methods (not just public) in",
             "the output.") do |value|
        @show_all = value
      end

      opt.separator nil

      opt.on("--exclude=PATTERN", "-x", Regexp,
             "Do not process files or directories",
             "matching PATTERN.") do |value|
        @exclude << value
      end

      opt.separator nil

      opt.on("--extension=NEW=OLD", "-E",
             "Treat files ending with .new as if they",
             "ended with .old. Using '-E cgi=rb' will",
             "cause xxx.cgi to be parsed as a Ruby file.") do |value|
        new, old = value.split(/=/, 2)

        unless new and old then
          raise OptionParser::InvalidArgument, "Invalid parameter to '-E'"
        end

        unless RDoc::ParserFactory.alias_extension old, new then
          raise OptionParser::InvalidArgument, "Unknown extension .#{old} to -E"
        end
      end

      opt.separator nil

      opt.on("--force-update", "-U",
             "Forces rdoc to scan all sources even if",
             "newer than the flag file.") do |value|
        @force_update = value
      end

      opt.separator nil

      opt.on("--pipe",
             "Convert RDoc on stdin to HTML") do
        @pipe = true
      end

      opt.separator nil

      opt.on("--threads=THREADS", Integer,
             "Number of threads to parse with.") do |threads|
        @threads = threads
      end

      opt.separator nil
      opt.separator "Generator Options:"
      opt.separator nil

      opt.on("--charset=CHARSET", "-c",
             "Specifies the output HTML character-set.") do |value|
        @charset = value
      end

      opt.separator nil

      generator_text = @generators.keys.map { |name| "  #{name}" }.sort

      opt.on("--fmt=FORMAT", "--format=FORMAT", "-f", @generators.keys,
             "Set the output formatter.  One of:", *generator_text) do |value|
        @generator_name = value.downcase
        setup_generator
      end

      opt.separator nil

      opt.on("--include=DIRECTORIES", "-i", Array,
             "Set (or add to) the list of directories to",
             "be searched when satisfying :include:",
             "requests. Can be used more than once.") do |value|
        @rdoc_include.concat value.map { |dir| dir.strip }
      end

      opt.separator nil

      opt.on("--line-numbers", "-N",
             "Include line numbers in the source code.") do |value|
        @include_line_numbers = value
      end

      opt.separator nil

      opt.on("--main=NAME", "-m",
             "NAME will be the initial page displayed.") do |value|
        @main_page = value
      end

      opt.separator nil

      opt.on("--output=DIR", "--op", "-o",
             "Set the output directory.") do |value|
        @op_dir = value
      end

      opt.separator nil

      opt.on("--show-hash", "-H",
             "A name of the form #name in a comment is a",
             "possible hyperlink to an instance method",
             "name. When displayed, the '#' is removed",
             "unless this option is specified.") do |value|
        @show_hash = value
      end

      opt.separator nil

      opt.on("--tab-width=WIDTH", "-w", OptionParser::DecimalInteger,
             "Set the width of tab characters.") do |value|
        @tab_width = value
      end

      opt.separator nil

      opt.on("--template=NAME", "-T",
             "Set the template used when generating",
             "output.") do |value|
        @template = value
      end

      opt.separator nil

      opt.on("--title=TITLE", "-t",
             "Set TITLE as the title for HTML output.") do |value|
        @title = value
      end

      opt.separator nil

      opt.on("--webcvs=URL", "-W",
             "Specify a URL for linking to a web frontend",
             "to CVS. If the URL contains a '\%s', the",
             "name of the current file will be",
             "substituted; if the URL doesn't contain a",
             "'\%s', the filename will be appended to it.") do |value|
        @webcvs = value
      end

      opt.separator nil
      opt.separator "Diagram Options:"
      opt.separator nil

      image_formats = %w[gif png jpg jpeg]
      opt.on("--image-format=FORMAT", "-I", image_formats,
             "Sets output image format for diagrams. Can",
             "be #{image_formats.join ', '}. If this option",
             "is omitted, png is used. Requires",
             "diagrams.") do |value|
        @image_format = value
      end

      opt.separator nil

      opt.on("--diagram", "-d",
             "Generate diagrams showing modules and",
             "classes. You need dot V1.8.6 or later to",
             "use the --diagram option correctly. Dot is",
             "available from http://graphviz.org") do |value|
        check_diagram
        @diagram = true
      end

      opt.separator nil

      opt.on("--fileboxes", "-F",
             "Classes are put in boxes which represents",
             "files, where these classes reside. Classes",
             "shared between more than one file are",
             "shown with list of files that are sharing",
             "them. Silently discarded if --diagram is",
             "not given.") do |value|
        @fileboxes = value
      end

      opt.separator nil
      opt.separator "ri Generator Options:"
      opt.separator nil

      opt.on("--ri", "-r",
             "Generate output for use by `ri`. The files",
             "are stored in the '.rdoc' directory under",
             "your home directory unless overridden by a",
             "subsequent --op parameter, so no special",
             "privileges are needed.") do |value|
        @generator_name = "ri"
        @op_dir = RDoc::RI::Paths::HOMEDIR
        setup_generator
      end

      opt.separator nil

      opt.on("--ri-site", "-R",
             "Generate output for use by `ri`. The files",
             "are stored in a site-wide directory,",
             "making them accessible to others, so",
             "special privileges are needed.") do |value|
        @generator_name = "ri"
        @op_dir = RDoc::RI::Paths::SITEDIR
        setup_generator
      end

      opt.separator nil

      opt.on("--merge", "-M",
             "When creating ri output, merge previously",
             "processed classes into previously",
             "documented classes of the same name.") do |value|
        @merge = value
      end

      opt.separator nil
      opt.separator "Generic Options:"
      opt.separator nil

      opt.on("--debug", "-D",
             "Displays lots on internal stuff.") do |value|
        $DEBUG_RDOC = value
      end

      opt.on("--quiet", "-q",
             "Don't show progress as we parse.") do |value|
        @verbosity = 0
      end

      opt.on("--verbose", "-v",
             "Display extra progress as we parse.") do |value|
        @verbosity = 2
      end

      opt.separator nil
      opt.separator 'Deprecated options - these warn when set'
      opt.separator nil

      opt.on("--inline-source", "-S") do |value|
        warn "--inline-source will be removed from RDoc on or after August 2009"
      end

      opt.on("--promiscuous", "-p") do |value|
        warn "--promiscuous will be removed from RDoc on or after August 2009"
      end

      opt.separator nil
    end

    argv.insert(0, *ENV['RDOCOPT'].split) if ENV['RDOCOPT']

    opts.parse! argv

    @files = argv.dup

    @rdoc_include << "." if @rdoc_include.empty?

    if @exclude.empty? then
      @exclude = nil
    else
      @exclude = Regexp.new(@exclude.join("|"))
    end

    check_files

    # If no template was specified, use the default template for the output
    # formatter

    @template ||= @generator_name

  rescue OptionParser::InvalidArgument, OptionParser::InvalidOption => e
    puts opts
    puts
    puts e
    exit 1
  end

  ##
  # Set the title, but only if not already set. This means that a title set
  # from the command line trumps one set in a source file

  def title=(string)
    @title ||= string
  end

  ##
  # Don't display progress as we process the files

  def quiet
    @verbosity.zero?
  end

  def quiet=(bool)
    @verbosity = bool ? 0 : 1
  end

  private

  ##
  # Set up an output generator for the format in @generator_name

  def setup_generator
    @generator = @generators[@generator_name]

    unless @generator then
      raise OptionParser::InvalidArgument, "Invalid output formatter"
    end
  end

  # Check that the right version of 'dot' is available.  Unfortunately this
  # doesn't work correctly under Windows NT, so we'll bypass the test under
  # Windows.

  def check_diagram
    return if RUBY_PLATFORM =~ /mswin|cygwin|mingw|bccwin/

    ok = false
    ver = nil

    IO.popen "dot -V 2>&1" do |io|
      ver = io.read
      if ver =~ /dot.+version(?:\s+gviz)?\s+(\d+)\.(\d+)/ then
        ok = ($1.to_i > 1) || ($1.to_i == 1 && $2.to_i >= 8)
      end
    end

    unless ok then
      if ver =~ /^dot.+version/ then
        $stderr.puts "Warning: You may need dot V1.8.6 or later to use\n",
          "the --diagram option correctly. You have:\n\n   ",
          ver,
          "\nDiagrams might have strange background colors.\n\n"
      else
        $stderr.puts "You need the 'dot' program to produce diagrams.",
          "(see http://www.research.att.com/sw/tools/graphviz/)\n\n"
        exit
      end
    end
  end

  ##
  # Check that the files on the command line exist

  def check_files
    @files.each do |f|
      stat = File.stat f rescue next
      raise RDoc::Error, "file '#{f}' not readable" unless stat.readable?
    end
  end

end

