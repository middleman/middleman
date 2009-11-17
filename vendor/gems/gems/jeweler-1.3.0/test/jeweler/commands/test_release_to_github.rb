require 'test_helper'

class Jeweler
  module Commands
    class TestReleaseToGithub < Test::Unit::TestCase

      rubyforge_command_context "running" do
        context "happily" do
          setup do
            stub(@command).clean_staging_area? { true }

            stub(@repo).checkout(anything)

            stub(@command).regenerate_gemspec!

            stub(@command).gemspec_changed? { true }
            stub(@command).commit_gemspec! { true }

            stub(@repo).push

            stub(@command).release_not_tagged? { true }

            @command.run
          end

          should "checkout master" do
            assert_received(@repo) {|repo| repo.checkout('master') }
          end

          should "regenerate gemspec" do
            assert_received(@command) {|command| command.regenerate_gemspec! }
          end

          should "commit gemspec" do
            assert_received(@command) {|command| command.commit_gemspec! }
          end

          should "push" do
            assert_received(@repo) {|repo| repo.push }
          end

        end

        context "with an unclean staging area" do
          setup do
            stub(@command).clean_staging_area? { false }
          end

          should 'raise error' do
            assert_raises RuntimeError, /try commiting/i do
              @command.run
            end
          end
        end

        context "with an unchanged gemspec" do
          setup do
            stub(@command).clean_staging_area? { true }

            stub(@repo).checkout(anything)

            stub(@command).regenerate_gemspec!

            stub(@command).gemspec_changed? { false }
            dont_allow(@command).commit_gemspec! { true }

            stub(@repo).push

            stub(@command).release_not_tagged? { true }

            @command.run
          end

          should "checkout master" do
            assert_received(@repo) {|repo| repo.checkout('master') }
          end

          should "regenerate gemspec" do
            assert_received(@command) {|command| command.regenerate_gemspec! }
          end

          should "push" do
            assert_received(@repo) {|repo| repo.push }
          end

        end

        context "with a release already tagged" do
          setup do
            stub(@command).clean_staging_area? { true }

            stub(@repo).checkout(anything)

            stub(@command).regenerate_gemspec!

            stub(@command).gemspec_changed? { true }
            stub(@command).commit_gemspec! { true }

            stub(@repo).push

            stub(@command).release_not_tagged? { false }

            @command.run
          end

          should "checkout master" do
            assert_received(@repo) {|repo| repo.checkout('master') }
          end

          should "regenerate gemspec" do
            assert_received(@command) {|command| command.regenerate_gemspec! }
          end

          should "commit gemspec" do
            assert_received(@command) {|command| command.commit_gemspec! }
          end

          should "push" do
            assert_received(@repo) {|repo| repo.push }
          end

        end

      end


      build_command_context "building from jeweler" do
        setup do
          @command = Jeweler::Commands::ReleaseToGithub.build_for(@jeweler)
        end

        should "assign gemspec" do
          assert_same @gemspec, @command.gemspec
        end

        should "assign version" do
          assert_same @version, @command.version
        end

        should "assign repo" do
          assert_same @repo, @command.repo
        end

        should "assign output" do
          assert_same @output, @command.output
        end

        should "assign gemspec_helper" do
          assert_same @gemspec_helper, @command.gemspec_helper
        end

        should "assign base_dir" do
          assert_same @base_dir, @command.base_dir
        end
      end

      context "clean_staging_area?" do

        should "be false if there added files" do
          repo = build_repo :added => %w(README)

          command = Jeweler::Commands::ReleaseToGithub.new :repo => repo

          assert ! command.clean_staging_area?
        end

        should "be false if there are changed files" do
          repo = build_repo :changed => %w(README)

          command = Jeweler::Commands::ReleaseToGithub.new
          command.repo = repo

          assert ! command.clean_staging_area?
        end

        should "be false if there are deleted files" do
          repo = build_repo :deleted => %w(README)

          command = Jeweler::Commands::ReleaseToGithub.new
          command.repo = repo

          assert ! command.clean_staging_area?
        end

        should "be true if nothing added, changed, or deleted" do
          repo = build_repo

          command = Jeweler::Commands::ReleaseToGithub.new
          command.repo = repo

          assert command.clean_staging_area?
        end
      end

      context "regenerate_gemspec!" do
        setup do
          @repo = Object.new
          stub(@repo) do
            add(anything)
            commit(anything)
          end

          @gemspec_helper = Object.new
          stub(@gemspec_helper) do
            write
            path {'zomg.gemspec'}
            update_version('1.2.3')
          end

          @output = StringIO.new

          @command                = Jeweler::Commands::ReleaseToGithub.new :output => @output,
                                                                   :repo => @repo,
                                                                   :gemspec_helper => @gemspec_helper,
                                                                   :version => '1.2.3'

          @command.regenerate_gemspec!
        end

        should "refresh gemspec version" do
          assert_received(@gemspec_helper) {|gemspec_helper| gemspec_helper.update_version('1.2.3') }
        end

        should "write gemspec" do
          assert_received(@gemspec_helper) {|gemspec_helper| gemspec_helper.write }
        end
      end

      context "commit_gemspec!" do
        setup do
          @repo = Object.new
          stub(@repo) do
            add(anything)
            commit(anything)
          end

          @gemspec_helper = Object.new
          stub(@gemspec_helper) do
            path {'zomg.gemspec'}
            update_version('1.2.3')
          end

          @output = StringIO.new

          @command                = Jeweler::Commands::ReleaseToGithub.new :output => @output,
                                                                   :repo => @repo,
                                                                   :gemspec_helper => @gemspec_helper,
                                                                   :version => '1.2.3'

          @command.commit_gemspec!
        end

        should "add gemspec to repository" do
          assert_received(@repo) {|repo| repo.add('zomg.gemspec') }
        end

        should "commit with commit message including version" do
          assert_received(@repo) {|repo| repo.commit("Regenerated gemspec for version 1.2.3") }
        end

      end

      context "release_tagged? when no tag exists" do
        setup do
          @repo = Object.new
          stub(@repo).tag('v1.2.3') { raise Git::GitTagNameDoesNotExist, tag }

          @output = StringIO.new

          @command                = Jeweler::Commands::ReleaseToGithub.new
          @command.output         = @output
          @command.repo           = @repo
          @command.version        = '1.2.3'
        end

        should_eventually "be true" do
          assert @command.release_not_tagged?
        end

      end

      context "release_tagged? when tag exists" do
        setup do
          @repo = Object.new
          stub(@repo) do
            tag('v1.2.3') { Object.new }
          end

          @output = StringIO.new

          @command                = Jeweler::Commands::ReleaseToGithub.new
          @command.output         = @output
          @command.repo           = @repo
          @command.version        = '1.2.3'
        end

        should_eventually "be false" do
          assert @command.release_not_tagged?
        end

      end

      def build_repo(options = {})
        status = build_status options
        repo = Object.new
        stub(repo).status { status }
        repo
      end

      def build_status(options = {})
        options = {:added => [], :deleted => [], :changed => []}.merge(options)

        status = Object.new
        stub(status) do
          added { options[:added] }
          deleted { options[:deleted] }
          changed { options[:changed] }
        end
        
      end
    end
  end
end
