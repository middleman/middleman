require 'test_helper'

class TestSpecification < Test::Unit::TestCase
  def setup
    remove_tmpdir!
    path = File.join(FIXTURE_DIR, "existing-project-with-version-yaml")
    Git.init(path)
    FileUtils.cp_r path, tmp_dir
    #breakpoint


    @spec = Gem::Specification.new
    @spec.extend(Jeweler::Specification)
    @spec.set_jeweler_defaults(tmp_dir)
  end

  def teardown
    remove_tmpdir!
  end

  context "Gem::Specification with Jeweler monkey-patches" do
    context "when setting defaults" do
      should_eventually "should populate `files'" do
        # this implementation changed to use ruby-git
        assert_equal %w{Rakefile VERSION.yml bin/foo_the_ultimate_bin lib/foo_the_ultimate_lib.rb }, @spec.files.sort
      end

      should "should populate `executables'" do
        assert_equal %w{ foo_the_ultimate_bin }, @spec.executables
      end

      context "with values already set" do
        setup do
          @spec.files = %w{ hey_include_me_in_gemspec }
          @spec.set_jeweler_defaults(fixture_dir)
        end

        should "not re-populate `files'" do
          assert_equal %w{ hey_include_me_in_gemspec }, @spec.files
        end
      end

      context "for rdoc" do
        should "be enabled" do
          assert @spec.has_rdoc
        end

        should "be utf-8" do
          assert @spec.rdoc_options.include?('--charset=UTF-8')
        end
      end
    end

    should "allow the user to concat files to the existing `files' array" do
      before = @spec.files.dup
      @spec.files << 'extra'

      assert_equal before + %w{ extra }, @spec.files
    end
  end
end
