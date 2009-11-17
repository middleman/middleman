require 'test_helper'

class Jeweler
  module Commands
    class TestSetupRubyforge < Test::Unit::TestCase
      def self.subject
        Jeweler::Commands::SetupRubyforge.new
      end

      rubyforge_command_context "package_exists?" do
        setup do
          stub(@gemspec).name { 'zomg' }
        end

        should "be true if rubyforge.lookup doesn't cause an Error" do
          mock(@rubyforge).lookup('package', 'zomg')

          assert @command.package_exists?
        end

        should "be false if rubyforge.lookup raises an error like: no <package_id> configured for <zomg>" do
          mock(@rubyforge).lookup('package', 'zomg') do
            raise RuntimeError, "no <package_id> configured for <zomg>"
          end

          assert ! @command.package_exists?
        end

        should "reraise any other Errors" do
          mock(@rubyforge).lookup('package', 'zomg') do
            raise RuntimeError, 'burnination!'
          end

          assert_raises RuntimeError, 'burnination!' do
            @command.package_exists?
          end
        end
      end

      rubyforge_command_context "create_package" do
        setup do
          stub(@gemspec).name { 'zomg' }
        end

        context "when everything is happy" do
          setup do
            stub(@gemspec).rubyforge_project { 'myproject' }
            stub(@rubyforge).create_package('myproject', 'zomg')

            @command.create_package
          end

          should "create zomg package to myproject on rubyforge" do
            assert_received(@rubyforge) {|rubyforge| rubyforge.create_package('myproject', 'zomg') }
          end

        end

        context "when rubyforge project not existing or being setup in ~/.rubyforge/autoconfig.yml" do
          setup do
            stub(@gemspec).rubyforge_project { 'myproject' }
            stub(@rubyforge).create_package('myproject', 'zomg')do
              raise RuntimeError, "no <group_id> configured for <myproject>"
            end
          end

          should "raise RubyForgeProjectNotConfiguredError" do
            assert_raises RubyForgeProjectNotConfiguredError do
              @command.create_package
            end
          end 
        end
      end


      rubyforge_command_context "rubyforge_project defined in gemspec and project existing on rubyforge" do
        setup do
          stub(@rubyforge).configure
          stub(@rubyforge).login

          stub(@gemspec).name { 'zomg' }
          stub(@gemspec).rubyforge_project { 'myproject' }

          stub(@command).package_exists? { false }
          stub(@command).create_package
          @command.run
        end

        should "configure rubyforge" do
          assert_received(@rubyforge) {|rubyforge| rubyforge.configure}
        end

        should "login to rubyforge" do
          assert_received(@rubyforge) {|rubyforge| rubyforge.login}
        end

        should "create zomg package to myproject on rubyforge" do
          assert_received(@command) {|command| command.create_package }
        end
      end

      rubyforge_command_context "rubyforge_project defined in gemspec, project and project already existing on rubyforge" do
        setup do
          stub(@rubyforge).configure
          stub(@rubyforge).login


          stub(@gemspec).name { 'zomg' }
          stub(@gemspec).rubyforge_project { 'myproject' }

          stub(@command).package_exists? { true }
          dont_allow(@command).create_package
          @command.run
        end

        should "configure rubyforge" do
          assert_received(@rubyforge) {|rubyforge| rubyforge.configure}
        end

        should "login to rubyforge" do
          assert_received(@rubyforge) {|rubyforge| rubyforge.login}
        end

      end
      

      rubyforge_command_context "rubyforge_project is not defined" do
        setup do
          stub(@gemspec).name { 'zomg' }
          stub(@gemspec).rubyforge_project { nil }
        end

        should "raise NoRubyForgeProjectConfigured" do
          assert_raises Jeweler::NoRubyForgeProjectInGemspecError do
            @command.run
          end
        end
      end

      rubyforge_command_context "rubyforge project not existing or being setup in ~/.rubyforge/autoconfig.yml" do
        setup do
          stub(@rubyforge).configure
          stub(@rubyforge).login

          stub(@gemspec).name { 'zomg' }
          stub(@gemspec).rubyforge_project { 'some_project_that_doesnt_exist' }

          stub(@command).package_exists? { false }
          stub(@command).create_package do
            raise RubyForgeProjectNotConfiguredError, 'some_project_that_doesnt_exist'
          end
        end

        should "raise RubyForgeProjectNotConfiguredError" do
          assert_raises RubyForgeProjectNotConfiguredError do
            @command.run
          end
        end 

      end

      build_command_context "build for jeweler" do
        setup do
          @command = Jeweler::Commands::SetupRubyforge.build_for(@jeweler)
        end

        should "assign gemspec" do
          assert_equal @gemspec, @command.gemspec
        end

        should "assign output" do
          assert_equal @output, @command.output
        end
      end

    end
  end
end
