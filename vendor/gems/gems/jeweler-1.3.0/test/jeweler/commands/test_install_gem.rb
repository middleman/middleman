require 'test_helper'

class Jeweler
  module Commands
    class TestInstallGem < Test::Unit::TestCase
      rubyforge_command_context "running" do
        setup do
          stub(@gemspec_helper).gem_path { 'pkg/zomg-1.1.1.gem' } 
          stub(@command).sudo_wrapper { 'sudo gem install --local pkg/zomg-1.1.1.gem' }
          stub(@command).sh

          @command.run
        end

        should "call sudo wrapper with gem install --local" do
          assert_received(@command) {|command| command.sudo_wrapper('gem install --local pkg/zomg-1.1.1.gem') }
        end

        should "call sh with output of sudo wrapper" do
          assert_received(@command) {|command| command.sh 'sudo gem install --local pkg/zomg-1.1.1.gem' }
        end
      end

      rubyforge_command_context "use_sudo?" do
        should "be false on mswin" do
          stub(@command).host_os { "i386-mswin32" }
          assert ! @command.use_sudo?
        end

        should "be false on windows" do
          stub(@command).host_os { "windows" }
          assert ! @command.use_sudo?
        end

        should "be false on cygwin" do
          stub(@command).host_os { "cygwin" }
          assert ! @command.use_sudo?
        end

        should "be true on basically anything else" do
          stub(@command).host_os { "darwin9" }
          assert @command.use_sudo?
        end
      end

      rubyforge_command_context "sudo_wrapper" do
        should "prefix sudo if needed" do
          stub(@command).use_sudo? { true }
          assert_equal "sudo blarg", @command.sudo_wrapper("blarg")
        end

        should "not prefix with sudo if unneeded" do
          stub(@command).use_sudo? { false }
          assert_equal "blarg", @command.sudo_wrapper("blarg")
        end
      end
      

      build_command_context "build for jeweler" do
        setup do
          @command = Jeweler::Commands::InstallGem.build_for(@jeweler)
        end

        should "assign gemspec helper" do
          assert_equal @gemspec_helper, @command.gemspec_helper
        end

        should "assign output" do
          assert_equal @output, @command.output
        end
      end
    end
  end
end
