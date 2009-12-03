require 'test_helper'
require 'fileutils'
require 'compass'
require 'compass/exec'
require 'timeout'

class RailsIntegrationTest < Test::Unit::TestCase
  include Compass::TestCaseHelper
  include Compass::CommandLineHelper
  include Compass::IoHelper
  include Compass::RailsHelper

  def setup
    Compass.reset_configuration!
  end

  def test_rails_install
    within_tmp_directory do
      generate_rails_app_directories("compass_rails")
      Dir.chdir "compass_rails" do
        compass("--rails", '--trace', ".") do |responder|
          responder.respond_to "Is this OK? (Y/n)", :with => "Y", :required => true
          responder.respond_to "Emit compiled stylesheets to public/stylesheets/compiled/? (Y/n)", :with => "Y", :required => true
        end
        # puts ">>>#{@last_result}<<<"
        assert_action_performed :create, "./app/stylesheets/screen.sass"
        assert_action_performed :create, "./config/initializers/compass.rb"
      end
    end
  rescue LoadError
    puts "Skipping rails test. Couldn't Load rails"
  end

  def test_rails_install_with_no_dialog
    within_tmp_directory do
      generate_rails_app_directories("compass_rails")
      Dir.chdir "compass_rails" do
        compass(*%w(--rails --trace --sass-dir app/stylesheets --css-dir public/stylesheets/compiled .))
        assert_action_performed :create, "./app/stylesheets/screen.sass"
        assert_action_performed :create, "./config/initializers/compass.rb"
      end
    end
  rescue LoadError
    puts "Skipping rails test. Couldn't Load rails"
  end
end
