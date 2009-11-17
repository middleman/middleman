require 'rubygems'
require 'tempfile'
require 'spec/expectations'
require 'fileutils'
require 'forwardable'
begin
  require 'spork'
rescue Gem::LoadError => ex
  gem 'spork', '>= 0.7.3' # Ensure correct spork version number to avoid false-negatives.
end

class CucumberWorld
  extend Forwardable
  def_delegators CucumberWorld, :examples_dir, :self_test_dir, :working_dir, :cucumber_lib_dir

  def self.examples_dir(subdir=nil)
    @examples_dir ||= File.expand_path(File.join(File.dirname(__FILE__), '../../examples'))
    subdir ? File.join(@examples_dir, subdir) : @examples_dir
  end

  def self.self_test_dir
    @self_test_dir ||= examples_dir('self_test')
  end

  def self.working_dir
    @working_dir ||= examples_dir('self_test/tmp')
  end

  def cucumber_lib_dir
    @cucumber_lib_dir ||= File.expand_path(File.join(File.dirname(__FILE__), '../../lib'))
  end

  def initialize
    @current_dir = self_test_dir
  end

  private
  attr_reader :last_exit_status, :last_stderr

  # The last standard out, with the duration line taken out (unpredictable)
  def last_stdout
    strip_1_9_paths(strip_duration(@last_stdout))
  end

  def strip_duration(s)
    s.gsub(/^\d+m\d+\.\d+s\n/m, "")
  end

  def strip_1_9_paths(s)
    s.gsub(/#{Dir.pwd}\/examples\/self_test\/tmp/m, ".").gsub(/#{Dir.pwd}\/examples\/self_test/m, ".")
  end

  def replace_duration(s, replacement)
    s.gsub(/\d+m\d+\.\d+s/m, replacement)
  end

  def replace_junit_duration(s, replacement)
    s.gsub(/\d+\.\d\d+/m, replacement)
  end

  def strip_ruby186_extra_trace(s)  
    s.gsub(/^.*\.\/features\/step_definitions(.*)\n/, "")
  end

  def create_file(file_name, file_content)
    file_content.gsub!("CUCUMBER_LIB", "'#{cucumber_lib_dir}'") # Some files, such as Rakefiles need to use the lib dir
    in_current_dir do
      FileUtils.mkdir_p(File.dirname(file_name)) unless File.directory?(File.dirname(file_name))
      File.open(file_name, 'w') { |f| f << file_content }
    end
  end

  def set_env_var(variable, value)
    @original_env_vars ||= {}
    @original_env_vars[variable] = ENV[variable] 
    ENV[variable]  = value
  end

  def background_jobs
    @background_jobs ||= []
  end

  def in_current_dir(&block)
    Dir.chdir(@current_dir, &block)
  end

  def run(command)
    stderr_file = Tempfile.new('cucumber')
    stderr_file.close
    in_current_dir do
      mode = Cucumber::RUBY_1_9 ? {:external_encoding=>"UTF-8"} : 'r'
      IO.popen("#{command} 2> #{stderr_file.path}", mode) do |io|
        @last_stdout = io.read
      end

      @last_exit_status = $?.exitstatus
    end
    @last_stderr = IO.read(stderr_file.path)
  end

  def run_spork_in_background(port = nil)
    pid = fork
    in_current_dir do
      if pid
        background_jobs << pid
      else
        # STDOUT.close
        # STDERR.close
        port_arg = port ? "-p #{port}" : ''
        cmd = "#{Cucumber::RUBY_BINARY} -I #{Cucumber::LIBDIR} #{Spork::BINARY} cuc #{port_arg}"
        exec cmd
      end
    end
    sleep (ENV["RUN_CODE_RUN"] ? 5.0 : 1.0)
  end

  def terminate_background_jobs
    background_jobs.each do |pid|
      Process.kill(Signal.list['TERM'], pid)
    end
  end

  def restore_original_env_vars
    @original_env_vars.each { |variable, value| ENV[variable] = value } if @original_env_vars
  end

end

World do
  CucumberWorld.new
end

Before do
  FileUtils.rm_rf CucumberWorld.working_dir
  FileUtils.mkdir CucumberWorld.working_dir
end

After do
  terminate_background_jobs
  restore_original_env_vars
end
