require  File.dirname(__FILE__)+'/test_helper'
require 'fileutils'
require 'compass'
require 'compass/exec'
require 'timeout'

class CommandLineTest < Test::Unit::TestCase
  include Compass::TestCaseHelper
  include Compass::CommandLineHelper

  def teardown
    Compass.configuration.reset!
  end

  def test_print_version
    compass "-vq"
    assert_match /\d+\.\d+\.\d+( [0-9a-f]+)?/, @last_result
  end

  def test_list_frameworks
    compass "--list-frameworks"
    assert_equal(%w(blueprint compass yui), @last_result.split.sort)
  end

  def test_basic_install
    within_tmp_directory do
      compass "basic"
      assert File.exists?("basic/src/screen.sass")
      assert File.exists?("basic/stylesheets/screen.css")
      assert_action_performed :directory, "basic/"
      assert_action_performed    :create, "basic/src/screen.sass"
      assert_action_performed   :compile, "basic/src/screen.sass"
      assert_action_performed    :create, "basic/stylesheets/screen.css"
    end
  end

  def test_framework_installs
    Compass::Frameworks::ALL.each do |framework|
      within_tmp_directory do
        compass *%W(--framework #{framework.name} #{framework.name}_project)
        assert File.exists?("#{framework.name}_project/src/screen.sass")
        assert File.exists?("#{framework.name}_project/stylesheets/screen.css")
        assert_action_performed :directory, "#{framework.name}_project/"
        assert_action_performed    :create, "#{framework.name}_project/src/screen.sass"
        assert_action_performed   :compile, "#{framework.name}_project/src/screen.sass"
        assert_action_performed    :create, "#{framework.name}_project/stylesheets/screen.css"
      end
    end
  end

  def test_basic_update
    within_tmp_directory do
      compass "basic"
      Dir.chdir "basic" do
        # basic update with timestamp caching
        compass
        assert_action_performed :unchanged, "src/screen.sass"
        # basic update with force option set
        compass "--force"
        assert_action_performed :compile, "src/screen.sass"
        assert_action_performed :identical, "stylesheets/screen.css"
      end
    end
  end

end