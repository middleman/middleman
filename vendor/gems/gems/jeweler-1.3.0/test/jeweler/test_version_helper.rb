require 'test_helper'

class TestVersionHelper < Test::Unit::TestCase

  VERSION_TMP_DIR = File.dirname(__FILE__) + '/version_tmp'

  def self.should_have_version(major, minor, patch, build=nil)
    should "have major version #{major}" do
      assert_equal major, @version_helper.major
    end

    should "have minor version #{minor}" do
      assert_equal minor, @version_helper.minor
    end

    should "have patch version #{patch}" do
      assert_equal patch, @version_helper.patch
    end

    should "have build version #{build}" do
      assert_equal build, @version_helper.build
    end

    version_s = [major, minor, patch, build].compact.join('.')
    should "render string as #{version_s.inspect}" do
      assert_equal version_s, @version_helper.to_s
    end

    #version_hash = {:major => major, :minor => minor, :patch => patch}
    #should "render hash as #{version_hash.inspect}" do
      #assert_equal version_hash, @version_helper.to_hash
    #end
    
  end

  context "VERSION.yml with 3.5.4" do
    setup do
      FileUtils.rm_rf VERSION_TMP_DIR
      FileUtils.mkdir_p VERSION_TMP_DIR

      build_version_yml VERSION_TMP_DIR, 3, 5, 4

      @version_helper = Jeweler::VersionHelper.new VERSION_TMP_DIR
    end

    should_have_version 3, 5, 4

    context "bumping major version" do
      setup { @version_helper.bump_major }
      should_have_version 4, 0, 0
    end

    context "bumping the minor version" do
      setup { @version_helper.bump_minor }
      should_have_version 3, 6, 0
    end

    context "bumping the patch version" do
      setup { @version_helper.bump_patch }
      should_have_version 3, 5, 5
    end
  end

  context "VERSION.yml with 3.5.4.a1" do
    setup do
      FileUtils.rm_rf VERSION_TMP_DIR
      FileUtils.mkdir_p VERSION_TMP_DIR

      build_version_yml VERSION_TMP_DIR, 3, 5, 4, 'a1'

      @version_helper = Jeweler::VersionHelper.new VERSION_TMP_DIR
    end

    should_have_version 3, 5, 4, 'a1'

    context "bumping major version" do
      setup { @version_helper.bump_major }
      should_have_version 4, 0, 0, nil
    end

    context "bumping the minor version" do
      setup { @version_helper.bump_minor }
      should_have_version 3, 6, 0, nil
    end

    context "bumping the patch version" do
      setup { @version_helper.bump_patch }
      should_have_version 3, 5, 5, nil
    end
  end

  context "VERSION with 3.5.4" do
    setup do
      FileUtils.rm_rf VERSION_TMP_DIR
      FileUtils.mkdir_p VERSION_TMP_DIR

      build_version_plaintext VERSION_TMP_DIR, 3, 5, 4

      @version_helper = Jeweler::VersionHelper.new VERSION_TMP_DIR
    end

    should_have_version 3, 5, 4

    context "bumping major version" do
      setup { @version_helper.bump_major }
      should_have_version 4, 0, 0
    end

    context "bumping the minor version" do
      setup { @version_helper.bump_minor }
      should_have_version 3, 6, 0
    end

    context "bumping the patch version" do
      setup { @version_helper.bump_patch }
      should_have_version 3, 5, 5
    end
  end

  context "VERSION with 3.5.4.a1" do
    setup do
      FileUtils.rm_rf VERSION_TMP_DIR
      FileUtils.mkdir_p VERSION_TMP_DIR

      build_version_plaintext VERSION_TMP_DIR, 3, 5, 4, 'a1'

      @version_helper = Jeweler::VersionHelper.new VERSION_TMP_DIR
    end

    should_have_version 3, 5, 4, 'a1'

    context "bumping major version" do
      setup { @version_helper.bump_major }
      should_have_version 4, 0, 0, nil
    end

    context "bumping the minor version" do
      setup { @version_helper.bump_minor }
      should_have_version 3, 6, 0, nil
    end

    context "bumping the patch version" do
      setup { @version_helper.bump_patch }
      should_have_version 3, 5, 5, nil
    end
  end

  context "Non-existant VERSION.yml" do
    setup do
      FileUtils.rm_rf VERSION_TMP_DIR
      FileUtils.mkdir_p VERSION_TMP_DIR
    end

    should "not raise error if the VERSION.yml doesn't exist" do
      assert_nothing_raised Jeweler::VersionYmlError do
        Jeweler::VersionHelper.new(VERSION_TMP_DIR)
      end
    end

    context "setting an initial version" do
      setup do
        @version_helper = Jeweler::VersionHelper.new(VERSION_TMP_DIR)
        @version_helper.update_to 0, 0, 1
      end

      should_have_version 0, 0, 1
      should "not create VERSION.yml" do
        assert ! File.exists?(File.join(VERSION_TMP_DIR, 'VERSION.yml'))
      end
      should "not create VERSION" do
        assert ! File.exists?(File.join(VERSION_TMP_DIR, 'VERSION'))
      end

      context "outputting" do
        setup do
          @version_helper.write
        end

        should "create VERSION" do
          assert File.exists?(File.join(VERSION_TMP_DIR, 'VERSION'))
        end

        context "re-reading VERSION" do
          setup do
            @version_helper = Jeweler::VersionHelper.new(VERSION_TMP_DIR)
          end

          should_have_version 0, 0, 1
        end
      end
    end
  end

  def build_version_yml(base_dir, major, minor, patch, build=nil)
    version_path = File.join(base_dir, 'VERSION.yml')

    File.open(version_path, 'w+') do |f|
      version_hash = {
        'major' => major.to_i,
        'minor' => minor.to_i,
        'patch' => patch.to_i
      }
      version_hash['build'] = build if build
      YAML.dump(version_hash, f)
    end
  end

  def build_version_plaintext(base_dir, major, minor, patch, build=nil)
    version_path = File.join(base_dir, 'VERSION')
    File.open(version_path, 'w+') do |f|
      f.puts [major, minor, patch, build].compact.join('.')
    end
  end
end
