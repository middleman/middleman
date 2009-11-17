require 'test_helper'

class TestJeweler < Test::Unit::TestCase

  def build_jeweler(base_dir = nil)
    base_dir ||= non_git_dir_path
    FileUtils.mkdir_p base_dir

    Jeweler.new(build_spec, base_dir)
  end

  def git_dir_path
    File.join(tmp_dir, 'git')
  end

  def non_git_dir_path
    File.join(tmp_dir, 'nongit')
  end

  def build_git_dir

    FileUtils.mkdir_p git_dir_path
    Dir.chdir git_dir_path do
      Git.init
    end
  end

  def build_non_git_dir
    FileUtils.mkdir_p non_git_dir_path
  end

  should "raise an error if a nil gemspec is given" do
    assert_raises Jeweler::GemspecError do
      Jeweler.new(nil)
    end
  end

  should "know if it is in a git repo" do
    build_git_dir

    assert build_jeweler(git_dir_path).in_git_repo?
  end

  should "know if it is not in a git repo" do
    build_non_git_dir

    jeweler = build_jeweler(non_git_dir_path)
    assert ! jeweler.in_git_repo?, "jeweler doesn't know that #{jeweler.base_dir} is not a git repository"
  end

  should "find the base repo" do
    jeweler = build_jeweler(File.dirname(File.expand_path(__FILE__)))
    assert_equal File.dirname(File.dirname(File.expand_path(__FILE__))), jeweler.git_base_dir
  end

  should "build and run write gemspec command when writing gemspec" do
    jeweler = build_jeweler

    command = Object.new
    mock(command).run

    mock(Jeweler::Commands::WriteGemspec).build_for(jeweler) { command }

    jeweler.write_gemspec
  end

  should "build and run validate gemspec command when validating gemspec" do
    jeweler = build_jeweler

    command = Object.new
    mock(command).run

    mock(Jeweler::Commands::ValidateGemspec).build_for(jeweler) { command }

    jeweler.validate_gemspec
  end

  should "build and run build gem command when building gem" do
    jeweler = build_jeweler

    command = Object.new
    mock(command).run

    mock(Jeweler::Commands::BuildGem).build_for(jeweler) { command }

    jeweler.build_gem
  end

  should "build and run build gem command when installing gem" do
    jeweler = build_jeweler

    command = Object.new
    mock(command).run

    mock(Jeweler::Commands::InstallGem).build_for(jeweler) { command }

    jeweler.install_gem
  end

  should "build and run bump major version command when bumping major version" do
    jeweler = build_jeweler

    command = Object.new
    mock(command).run

    mock(Jeweler::Commands::Version::BumpMajor).build_for(jeweler) { command }

    jeweler.bump_major_version
  end

  should "build and run bump minor version command when bumping minor version" do
    jeweler = build_jeweler

    command = Object.new
    mock(command).run

    mock(Jeweler::Commands::Version::BumpMinor).build_for(jeweler) { command }

    jeweler.bump_minor_version
  end

  should "build and run write version command when writing version" do
    jeweler = build_jeweler

    command = Object.new
    mock(command).run
    mock(command).major=(1)
    mock(command).minor=(5)
    mock(command).patch=(2)
    mock(command).build=('a1')

    mock(Jeweler::Commands::Version::Write).build_for(jeweler) { command }

    jeweler.write_version(1, 5, 2, 'a1')
  end

  should "build and run release to github command when running release_gem_to_github" do
    jeweler = build_jeweler

    command = Object.new
    mock(command).run

    mock(Jeweler::Commands::ReleaseToGithub).build_for(jeweler) { command }

    jeweler.release_gem_to_github
  end

  should "build and run release to git command when running release_to_git" do
    jeweler = build_jeweler

    command = Object.new
    mock(command).run

    mock(Jeweler::Commands::ReleaseToGit).build_for(jeweler) { command }

    jeweler.release_to_git
  end

  should "build and run release to rubyforge command when running release to rubyforge" do
    jeweler = build_jeweler

    command = Object.new
    mock(command).run

    mock(Jeweler::Commands::ReleaseToRubyforge).build_for(jeweler) { command }

    jeweler.release_gem_to_rubyforge
  end


  should "respond to gemspec_helper" do
    assert_respond_to build_jeweler, :gemspec_helper
  end

  should "respond to version_helper" do
    assert_respond_to build_jeweler, :version_helper
  end

  should "respond to repo" do
    assert_respond_to build_jeweler, :repo
  end

  should "respond to commit" do
    assert_respond_to build_jeweler, :commit
  end

end
