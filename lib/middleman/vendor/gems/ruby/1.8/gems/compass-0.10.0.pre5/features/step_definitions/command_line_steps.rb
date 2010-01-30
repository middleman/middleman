require 'spec/expectations'
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../../test')))

require 'test_helper'

require 'compass/exec'

include Compass::CommandLineHelper
include Compass::IoHelper
include Compass::RailsHelper

Before do
  Compass.reset_configuration!
  @cleanup_directories = []
  @original_working_directory = Dir.pwd
end
 
After do
  Dir.chdir @original_working_directory
  @cleanup_directories.each do |dir|
    FileUtils.rm_rf dir
  end
end

# Given Preconditions
Given %r{^I am using the existing project in ([^\s]+)$} do |project|
  tmp_project = "tmp_#{File.basename(project)}"
  @cleanup_directories << tmp_project
  FileUtils.cp_r project, tmp_project
  Dir.chdir tmp_project
end

Given %r{^I am in the parent directory$} do
  Dir.chdir ".."
end

Given /^I'm in a newly created rails project: (.+)$/ do |project_name|
  @cleanup_directories << project_name
  begin
    generate_rails_app project_name
    Dir.chdir project_name
  rescue LoadError
    pending "Missing Ruby-on-rails gems: sudo gem install rails"
  end
end

Given /^I should clean up the directory: (\w+)$/ do |directory|
  @cleanup_directories << directory
end

# When Actions are performed
When /^I create a project using: compass create ([^\s]+) ?(.+)?$/ do |dir, args|
  @cleanup_directories << dir
  compass 'create', dir, *(args || '').split
end

When /^I initialize a project using: compass init ?(.+)?$/ do |args|
  compass 'init', *(args || '').split
end

When /^I run: compass ([^\s]+) ?(.+)?$/ do |command, args|
  compass command, *(args || '').split
end

When /^I run in a separate process: compass ([^\s]+) ?(.+)?$/ do |command, args|
  unless @other_process = fork 
    @last_result = ''
    @last_error = ''
    Signal.trap("HUP") do
      open('/tmp/last_result.compass_test.txt', 'w') do |file|
        file.puts $stdout.string
      end
      open('/tmp/last_error.compass_test.txt', 'w') do |file|
        file.puts @stderr.string
      end
      exit!
    end
    # this command will run forever
    # we kill it with a HUP signal from the parent process.
    args = (args || '').split
    args << { :wait => 5 }
    compass command, *args
    exit!
  end
end

When /^I shutdown the other process$/ do
  Process.kill("HUP", @other_process)
  Process.wait
  @last_result = File.read('/tmp/last_result.compass_test.txt')
  @last_error = File.read('/tmp/last_error.compass_test.txt')
end

When /^I touch ([^\s]+)$/ do |filename|
  FileUtils.touch filename
end

When /^I wait ([\d.]+) seconds?$/ do |count|
  sleep count.to_f
end

When /^I add some sass to ([^\s]+)$/ do |filename|
  open(filename, "w+") do |file|
    file.puts ".added .some .arbitrary"
    file.puts "  sass: code"
  end
end

# Then postconditions
Then /^a directory ([^ ]+) is (not )?created$/ do |directory, negated|
  File.directory?(directory).should == !negated
end
 
Then /an? \w+ file ([^ ]+) is (not )?created/ do |filename, negated|
  File.exists?(filename).should == !negated
end

Then /an? \w+ file ([^ ]+) is reported created/ do |filename|
  @last_result.should =~ /create #{Regexp.escape(filename)}/
end

Then /a \w+ file ([^ ]+) is (?:reported )?compiled/ do |filename|
  @last_result.should =~ /compile #{Regexp.escape(filename)}/
end

Then /a \w+ file ([^ ]+) is reported unchanged/ do |filename|
  @last_result.should =~ /unchanged #{Regexp.escape(filename)}/
end

Then /a \w+ file ([^ ]+) is reported identical/ do |filename|
  @last_result.should =~ /identical #{Regexp.escape(filename)}/
end

Then /a \w+ file ([^ ]+) is reported overwritten/ do |filename|
  @last_result.should =~ /overwrite #{Regexp.escape(filename)}/
end

Then /a \w+ file ([^ ]+) is not mentioned/ do |filename|
  @last_result.should_not =~ /#{Regexp.escape(filename)}/
end

Then /I am told how to link to ([^ ]+) for media "([^"]+)"/ do |stylesheet, media|
  @last_result.should =~ %r{<link href="#{stylesheet}" media="#{media}" rel="stylesheet" type="text/css" />}
end

Then /I am told how to conditionally link "([^"]+)" to ([^ ]+) for media "([^"]+)"/ do |condition, stylesheet, media|
  @last_result.should =~ %r{<!--\[if #{condition}\]>\s+<link href="#{stylesheet}" media="#{media}" rel="stylesheet" type="text/css" />\s+<!\[endif\]-->}mi
end

Then /^an error message is printed out: (.+)$/ do |error_message|
  @last_error.should =~ Regexp.new(Regexp.escape(error_message))
end

Then /^the command exits with a non\-zero error code$/ do
  @last_exit_code.should_not == 0
end


Then /^I am congratulated$/ do
  @last_result.should =~ /Congratulations!/
end

Then /^I am told that I can place stylesheets in the ([^\s]+) subdirectory$/ do |subdir|
  @last_result.should =~ /You may now add sass stylesheets to the #{subdir} subdirectory of your project./
end

Then /^I am told how to compile my sass stylesheets$/ do
  @last_result.should =~ /You must compile your sass stylesheets into CSS when they change.\nThis can be done in one of the following ways:/
end

Then /^I should be shown a list of "([^"]+)" commands$/ do |kind|
  @last_result.should =~ /^#{kind.capitalize} Commands:$/
  @last_command_list = []
  found = false
  indent = nil
  @last_result.split("\n").each do |line|
    if line =~ /^#{kind.capitalize} Commands:$/
      found = true
    elsif found && line =~ /^\s+/
      @last_command_list << line
    elsif found && line =~ /^$|^\w/
      break
    end
  end

end

Then /^the list of commands should describe the ([^ ]+) command$/ do |command|
  @last_result.should =~ /^\s+\* #{command}\s+- [A-Z].+$/
end

Then /^the following configuration properties are set in ([^ ]+):$/ do |config_file, table|
  
  config = Compass::Configuration::Data.new_from_file(config_file)
  table.hashes.each do |hash|
   config.send(hash['property']).should == hash['value']
  end
end

Then /^my css is validated$/ do
  if @last_error =~ /The Compass CSS Validator could not be loaded/
    pending "Missing Dependency: sudo gem install chriseppstein-compass-validator"
  else
    @last_result.should =~ /Compass CSS Validator/
  end
end

Then /^I am informed that my css is valid.$/ do
  @last_result.should =~ /Your CSS files are valid\./
end

Then /^I am told statistics for each file:$/ do |table|
  # table is a Cucumber::Ast::Table
  table.raw.each do |row|
    re = Regexp.new row.join(' *\| *')
    @last_result.should =~ re
  end
end

Then /^I should see the following "([^"]+)" commands:$/ do |kind, table|


  Then %Q{I should be shown a list of "#{kind}" commands}

  commands = @last_command_list.map{|c| c =~ /^\s+\* ([^ ]+)\s+- [A-Z].+$/; [$1]}
  table.diff!(commands)
end
     

Then /^the image ([^ ]+) has a size of (\d+)x(\d+)$/ do |file, width, height| 
  # see http://snippets.dzone.com/posts/show/805
  IO.read(file)[0x10..0x18].unpack('NN').should == [width.to_i, height.to_i]
end

