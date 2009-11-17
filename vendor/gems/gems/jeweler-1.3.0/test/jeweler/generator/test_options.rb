require 'test_helper'

class TestOptions < Test::Unit::TestCase

  def setup
    set_default_git_config
    stub_git_config valid_git_config
  end

  def self.should_have_testing_framework(testing_framework)
    should "use #{testing_framework} for testing" do
      assert_equal testing_framework.to_sym, @options[:testing_framework]
    end
  end

  def self.should_have_docmentation_framework(documentation_framework)
    should "use #{documentation_framework} for documentation" do
      assert_equal documentation_framework.to_sym, @options[:documentation_framework]
    end
  end

  def setup_options(*arguments)
    @options = Jeweler::Generator::Options.new(["project_name"] + arguments)
  end

  def self.for_options(*options)
    context options.join(' ') do
      setup { setup_options *options }
      yield
    end
  end

  context "default options" do
    setup { setup_options }
    should_have_testing_framework :shoulda
    should_have_docmentation_framework :rdoc
    should 'not create repository' do
      assert ! @options[:create_repo]
    end
    should "have project name" do
      assert_equal "project_name", @options[:project_name]
    end

    should "use github username from git config" do
      assert_equal @github_user, @options[:github_username]
    end

    should "use github token from git config" do
      assert_equal @github_token, @options[:github_token]
    end

    should "use user name from git config" do
      assert_equal @git_name, @options[:user_name]
    end

    should "use user email from git config" do
      assert_equal @git_email, @options[:user_email]
    end
  end

  for_options "--bacon" do
    should_have_testing_framework :bacon
  end

  for_options '--micronaut' do
    should_have_testing_framework :micronaut
  end

  for_options '--minitest' do
    should_have_testing_framework :minitest
  end

  for_options '--rspec' do
    should_have_testing_framework :rspec
  end

  for_options '--shoulda' do
    should_have_testing_framework :shoulda
  end

  for_options "--testunit" do
    should_have_testing_framework :testunit
  end

  for_options "--testspec" do
    should_have_testing_framework :testspec
  end

  for_options '--cucumber' do
    should 'enable cucumber' do
      assert_equal true, @options[:use_cucumber]
    end
  end

  for_options '--reek' do
    should 'enable reek' do
      assert_equal true, @options[:use_reek]
    end
  end

  for_options '--roodi' do
    should 'enable roodi' do
      assert_equal true, @options[:use_roodi]
    end
  end

  for_options '--create-repo' do
    should 'create repository' do
      assert @options[:create_repo]
    end
  end

  for_options '--rubyforge' do
    should 'enable rubyforge' do
      assert @options[:rubyforge]
    end
  end

  for_options '--rdoc' do
    should_have_docmentation_framework :rdoc
  end

  for_options '--yard' do
    should_have_docmentation_framework :yard
  end

  for_options '--summary', 'zomg so awesome' do
    should 'have summary zomg so awesome' do
      assert_equal 'zomg so awesome', @options[:summary]
    end
  end

  for_options '--description', 'Descriptive' do
    should 'have description Descriptive' do
      assert_equal 'Descriptive', @options[:description]
    end
  end

  for_options '--directory', 'foo' do
    should 'have directory foo' do
      assert_equal 'foo', @options[:directory]
    end
  end

  for_options '--help' do
    should 'show help' do
      assert @options[:show_help]
    end
  end

  for_options '-h' do
    should 'show help' do
      assert @options[:show_help]
    end
  end

  for_options '--zomg-invalid' do
    should 'be an invalid argument' do
      assert @options[:invalid_argument]
    end
  end

  for_options '--user-name', 'myname' do
    should "set user name" do
      assert_equal 'myname', @options[:user_name]
    end
  end

  for_options '--user-email', 'myname@mydomain.com' do
    should "set user email" do
      assert_equal 'myname@mydomain.com', @options[:user_email]
    end
  end

  for_options '--homepage', 'http://zomg.com' do
    should 'set hoempage' do
      assert_equal 'http://zomg.com', @options[:homepage]
    end
  end

  for_options '--git-remote', 'git@my-awesome-domain.com:zomg.git' do
    should 'set the git remote' do
      assert_equal 'git@my-awesome-domain.com:zomg.git', @options[:git_remote]
    end
  end

  for_options '--github-username', 'mygithub' do
    should "set github username" do
      assert_equal 'mygithub', @options[:github_username]
    end
  end

  for_options '--github-token', 'mygithubtoken' do
    should "set github token" do
      assert_equal 'mygithubtoken', @options[:github_token]
    end
  end

  context "merging options" do
    should "take options from each" do
      options = Jeweler::Generator::Options.new(["--rspec"]).
        merge Jeweler::Generator::Options.new(["--create-repo"])
      assert_equal :rspec, options[:testing_framework]
      assert options[:create_repo]
    end

    should "shadow options" do
      options = Jeweler::Generator::Options.new(["--bacon"]).
        merge Jeweler::Generator::Options.new(["--rspec"])
      assert_equal :rspec, options[:testing_framework]
    end
  end
end
