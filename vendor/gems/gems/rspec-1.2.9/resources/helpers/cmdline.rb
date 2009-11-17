require 'spec'

# Uncommenting next line will break the output feature (no output!!)
# rspec_options
options = Spec::Runner::OptionParser.parse(
  ARGV, $stderr, $stdout
)
Spec::Runner::CommandLine.run(options)
