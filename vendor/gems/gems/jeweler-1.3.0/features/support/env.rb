$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'jeweler'

begin
  require 'mocha'
  require 'output_catcher'
rescue LoadError => e
  puts "*" * 80
  puts "Some dependencies needed to run tests were missing. Run the following command to find them:"
  puts
  puts "\trake check_dependencies:development"
  puts "*" * 80
  exit 1
end


require 'test/unit/assertions'

World(Test::Unit::Assertions)

def yank_task_info(content, task)
  if content =~ /#{Regexp.escape(task)}.new(\(.*\))? do \|(.*?)\|(.*?)end/m
    [$2, $3]
  end
end

def fixture_dir
  File.expand_path File.join(File.dirname(__FILE__), '..', '..', 'test', 'fixtures')
end
