require 'test/unit'

require 'rubygems'
require 'rake'

begin
  require 'ruby-debug'
rescue LoadError
end

begin
  require 'shoulda'
  require 'rr'
  require 'redgreen'
rescue LoadError => e
  puts "*" * 80
  puts "Some dependencies needed to run tests were missing. Run the following command to find them:"
  puts
  puts "\trake check_dependencies:development"
  puts "*" * 80
  exit 1
end

require 'time'

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'jeweler'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'shoulda_macros/jeweler_macros'

TMP_DIR = '/tmp/jeweler_test'
FIXTURE_DIR = File.expand_path('../fixtures', __FILE__)

class RubyForgeStub
  attr_accessor :userconfig, :autoconfig
  def initialize
    @userconfig = {}
    @autoconfig = {}
  end
end

class Test::Unit::TestCase
  include RR::Adapters::TestUnit unless include?(RR::Adapters::TestUnit)

  def tmp_dir
    TMP_DIR
  end

  def fixture_dir
    File.join(FIXTURE_DIR, 'bar')
  end

  def remove_tmpdir!
    FileUtils.rm_rf(tmp_dir)
  end

  def create_tmpdir!
    FileUtils.mkdir_p(tmp_dir)
  end

  def build_spec(*files)
    Gem::Specification.new do |s|
      s.name = "bar"
      s.summary = "Simple and opinionated helper for creating Rubygem projects on GitHub"
      s.email = "josh@technicalpickles.com"
      s.homepage = "http://github.com/technicalpickles/jeweler"
      s.description = "Simple and opinionated helper for creating Rubygem projects on GitHub"
      s.authors = ["Josh Nichols"]
      s.files = FileList[*files] unless files.empty?
      s.version = '0.1.1'
    end
  end

  def self.gemcutter_command_context(description, &block)
    context description do
      setup do
        @command = eval(self.class.name.gsub(/::Test/, '::')).new

        if @command.respond_to? :gemspec_helper=
          @gemspec_helper = Object.new
          @command.gemspec_helper = @gemspec_helper
        end

        if @command.respond_to? :output
          @output = StringIO.new
          @command.output = @output
        end
      end

      context "", &block
    end
  end

  def self.rubyforge_command_context(description, &block)
    context description do
      setup do
        @command = eval(self.class.name.gsub(/::Test/, '::')).new

        if @command.respond_to? :gemspec=
          @gemspec = Object.new
          @command.gemspec = @gemspec
        end

        if @command.respond_to? :gemspec_helper=
          @gemspec_helper = Object.new
          @command.gemspec_helper = @gemspec_helper
        end

        if @command.respond_to? :rubyforge=
          @rubyforge = RubyForgeStub.new
          @command.rubyforge = @rubyforge
        end

        if @command.respond_to? :output
          @output = StringIO.new
          @command.output = @output
        end

        if @command.respond_to? :repo
          @repo = Object.new
          @command.repo = @repo 
        end
      end

      context "", &block
    end
  end

  def self.build_command_context(description, &block)
    context description do
      setup do

        @repo           = Object.new
        @version_helper = Object.new
        @gemspec        = Object.new
        @commit         = Object.new
        @version        = Object.new
        @output         = Object.new
        @base_dir       = Object.new
        @gemspec_helper = Object.new
        @rubyforge      = Object.new

        @jeweler        = Object.new

        stub(@jeweler).repo           { @repo }
        stub(@jeweler).version_helper { @version_helper }
        stub(@jeweler).gemspec        { @gemspec }
        stub(@jeweler).commit         { @commit }
        stub(@jeweler).version        { @version }
        stub(@jeweler).output         { @output }
        stub(@jeweler).gemspec_helper { @gemspec_helper }
        stub(@jeweler).base_dir       { @base_dir }
        stub(@jeweler).rubyforge    { @rubyforge }
      end

      context "", &block
    end

  end

  def stub_git_config(options = {})
    stub(Git).global_config() { options }
  end

  def set_default_git_config
    @project_name = 'the-perfect-gem'
    @git_name = 'foo'
    @git_email = 'bar@example.com'
    @github_user = 'technicalpickles'
    @github_token = 'zomgtoken'
  end

  def valid_git_config
    { 'user.name' => @git_name, 'user.email' => @git_email, 'github.user' => @github_user, 'github.token' => @github_token }
  end
end
