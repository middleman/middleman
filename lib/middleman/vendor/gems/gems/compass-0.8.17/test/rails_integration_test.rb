require  File.join(File.dirname(__FILE__),'test_helper')
require 'fileutils'
require 'compass'
require 'compass/exec'
require 'timeout'

class RailsIntegrationTest < Test::Unit::TestCase
  include Compass::TestCaseHelper
  include Compass::CommandLineHelper

  def setup
    Compass.configuration.reset!
  end

  def test_rails_install
    within_tmp_directory do
      generate_rails_app_directories("compass_rails")
      Dir.chdir "compass_rails" do
        compass("--rails", '--trace', ".") do |responder|
          responder.respond_to "Is this OK? (Y/n) ", :with => "Y", :required => true
          responder.respond_to "Emit compiled stylesheets to public/stylesheets/compiled/? (Y/n) ", :with => "Y", :required => true
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


  def generate_rails_app_directories(name)
    Dir.mkdir name
    Dir.mkdir File.join(name, "config")
    Dir.mkdir File.join(name, "config", "initializers")
  end

  # Generate a rails application without polluting our current set of requires
  # with the rails libraries. This will allow testing against multiple versions of rails
  # by manipulating the load path.
  def generate_rails_app(name)
    if pid = fork
      Process.wait(pid)
      if $?.exitstatus == 2
        raise LoadError, "Couldn't load rails"
      elsif $?.exitstatus != 0
        raise "Failed to generate rails application."
      end
    else
      begin
        require 'rails/version'
        require 'rails_generator'
        require 'rails_generator/scripts/generate'
        Rails::Generator::Base.use_application_sources!
        capture_output do
          Rails::Generator::Base.logger = Rails::Generator::SimpleLogger.new $stdout
          Rails::Generator::Scripts::Generate.new.run([name], :generator => 'app')
        end
      rescue LoadError
        Kernel.exit(2)
      rescue => e
        $stderr.puts e
        Kernel.exit!(1)
      end
      Kernel.exit!(0)
    end
  end

end