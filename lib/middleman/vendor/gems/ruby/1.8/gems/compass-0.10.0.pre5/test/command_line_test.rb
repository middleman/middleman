require 'test_helper'
require 'fileutils'
require 'compass'
require 'compass/exec'
require 'timeout'

class CommandLineTest < Test::Unit::TestCase
  include Compass::TestCaseHelper
  include Compass::CommandLineHelper
  include Compass::IoHelper

  def teardown
    Compass.reset_configuration!
  end

  def test_print_version
    compass "-vq"
    assert_match /\d+\.\d+\.\d+( [0-9a-f]+)?/, @last_result
  end

  def test_list_frameworks
    compass "--list-frameworks"
    assert_equal(%w(blueprint compass), @last_result.split.sort)
  end

  def test_basic_install
    within_tmp_directory do
      compass "--boring", "basic"
      assert File.exists?("basic/src/screen.sass")
      assert File.exists?("basic/stylesheets/screen.css")
      assert_action_performed :directory, "basic/"
      assert_action_performed    :create, "basic/src/screen.sass"
      assert_action_performed   :compile, "basic/src/screen.sass"
      assert_action_performed    :create, "basic/stylesheets/screen.css"
    end
  end

  Compass::Frameworks::ALL.each do |framework|
    define_method "test_#{framework.name}_installation" do
      within_tmp_directory do
        compass *%W(--boring --framework #{framework.name} #{framework.name}_project)
        assert File.exists?("#{framework.name}_project/src/screen.sass"), "src/screen.sass is missing. Found: #{Dir.glob("#{framework.name}_project/**/*").join(", ")}"
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
      compass "--boring", "basic"
      Dir.chdir "basic" do
        # basic update with timestamp caching
        compass "--boring"
        assert_action_performed :unchanged, "src/screen.sass"
        # basic update with force option set
        compass "--force", "--boring"
        assert_action_performed :compile, "src/screen.sass"
        assert_action_performed :identical, "stylesheets/screen.css"
      end
    end
  end

end
