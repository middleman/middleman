module Compass::Exec::GlobalOptionsParser
  def set_options(opts)
    super
    set_global_options(opts)
  end
  def set_global_options(opts)
    opts.on('-r LIBRARY', '--require LIBRARY',
            "Require the given ruby LIBRARY before running commands.",
            "  This is used to access compass plugins without having a",
            "  project configuration file.") do |library|
      ::Compass.configuration.require library
            end

    opts.on('-q', '--quiet', :NONE, 'Quiet mode.') do
      self.options[:quiet] = true
    end

    opts.on('--trace', :NONE, 'Show a full stacktrace on error') do
      self.options[:trace] = true
    end

    opts.on('--force', :NONE, 'Allows some failing commands to succeed instead.') do
      self.options[:force] = true
    end

    opts.on('--dry-run', :NONE, 'Dry Run. Tells you what it plans to do.') do
      self.options[:dry_run] = true
    end

    opts.on('--boring', :NONE, 'Turn off colorized output.') do
      self.options[:color_output] = false
    end

    opts.on_tail("-?", "-h", "--help", "Show this message") do
      puts opts
      exit
    end

  end

end
