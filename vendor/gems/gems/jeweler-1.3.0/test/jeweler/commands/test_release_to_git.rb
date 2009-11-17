require 'test_helper'

class Jeweler
  module Commands
    class TestReleaseToGit < Test::Unit::TestCase

      rubyforge_command_context "running" do
        context "happily" do
          setup do
            stub(@command).clean_staging_area? { true }

            stub(@repo).checkout(anything)
            stub(@repo) do
              add_tag(anything)
              push(anything, anything)
            end

            stub(@repo).push

            stub(@command).release_not_tagged? { true }

            @command.run
          end

          should "checkout master" do
            assert_received(@repo) {|repo| repo.checkout('master') }
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

        context "with a release already tagged" do
          setup do
            stub(@command).clean_staging_area? { true }

            stub(@repo).checkout(anything)

            stub(@repo).push

            stub(@command).release_not_tagged? { false }

            @command.run
          end

          should "checkout master" do
            assert_received(@repo) {|repo| repo.checkout('master') }
          end

          should "push" do
            assert_received(@repo) {|repo| repo.push }
          end

        end

      end


      build_command_context "building from jeweler" do
        setup do
          @command = Jeweler::Commands::ReleaseToGit.build_for(@jeweler)
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

          command = Jeweler::Commands::ReleaseToGit.new :repo => repo

          assert ! command.clean_staging_area?
        end

        should "be false if there are changed files" do
          repo = build_repo :changed => %w(README)

          command = Jeweler::Commands::ReleaseToGit.new
          command.repo = repo

          assert ! command.clean_staging_area?
        end

        should "be false if there are deleted files" do
          repo = build_repo :deleted => %w(README)

          command = Jeweler::Commands::ReleaseToGit.new
          command.repo = repo

          assert ! command.clean_staging_area?
        end

        should "be true if nothing added, changed, or deleted" do
          repo = build_repo

          command = Jeweler::Commands::ReleaseToGit.new
          command.repo = repo

          assert command.clean_staging_area?
        end
      end

      context "release_tagged? when no tag exists" do
        setup do
          @repo = Object.new
          stub(@repo).tag('v1.2.3') { raise Git::GitTagNameDoesNotExist, tag }

          @output = StringIO.new

          @command                = Jeweler::Commands::ReleaseToGit.new
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

          @command                = Jeweler::Commands::ReleaseToGit.new
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
