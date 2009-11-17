require "spec_helper"

triggering_double_output = Spec::Runner.options
options = Spec::Runner::OptionParser.parse(
  [File.dirname(__FILE__) + "/output_one_time_fixture.rb"], $stderr, $stdout
)
Spec::Runner::CommandLine.run(options)
