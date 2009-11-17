require 'test_helper'

class TestGeneratorInitialization < Test::Unit::TestCase
  def setup
    set_default_git_config
  end

  context "given a nil github repo name" do
    setup do
      stub_git_config
    end

    should 'raise NoGithubRepoNameGiven' do
      assert_raise Jeweler::NoGitHubRepoNameGiven do
        Jeweler::Generator.new()
      end
    end
  end

  context "without git user's name set" do
    setup do
      stub_git_config 
    end

    should 'raise an NoGitUserName' do
      assert_raise Jeweler::NoGitUserName do
        Jeweler::Generator.new(:project_name => @project_name, :testing_framework => :shoulda, :documentation_framework => :rdoc)
      end
    end
  end

  context "without git user's email set" do
    setup do
      stub_git_config 
    end

    should 'raise NoGitUserEmail' do
      assert_raise Jeweler::NoGitUserEmail do
        Jeweler::Generator.new(:project_name => @project_name, :user_name => @git_name, :testing_framework => :shoulda, :documentation_framework => :rdoc)
      end
    end
  end

  context "without github username set" do
    setup do
      stub_git_config
    end

    should 'raise NotGitHubUser' do
      assert_raise Jeweler::NoGitHubUser do
        Jeweler::Generator.new(:project_name => @project_name, :user_name => @git_name, :user_email => @git_email, :testing_framework => :shoulda, :documentation_framework => :rdoc)
      end
    end
  end
  
  context "without github token set" do
    setup do
      stub_git_config
    end

    should 'raise NoGitHubToken if creating repo' do
      assert_raise Jeweler::NoGitHubToken do
        Jeweler::Generator.new(:project_name => @project_name, :user_name => @git_name, :user_email => @git_email, :github_username => @github_user, :create_repo => true, :testing_framework => :shoulda, :documentation_framework => :rdoc)
      end
    end
  end

  def build_generator(options = {})
    defaults = { :project_name => @project_name,
                 :user_name => @git_name,
                 :user_email => @git_email,
                 :github_username => @github_user,
                 :github_token => @github_token,
                 :testing_framework =>             :shoulda,
                 :documentation_framework =>       :rdoc }

    options = defaults.merge(options)
    Jeweler::Generator.new(options) 
  end

  context "default configuration" do
    setup do
      stub_git_config
      @generator = build_generator
    end

    should "use shoulda for testing" do
      assert_equal :shoulda, @generator.testing_framework
    end

    should "use rdoc for documentation" do
      assert_equal :rdoc, @generator.documentation_framework
    end

    should "set todo in summary" do
      assert_match /todo/i, @generator.summary
    end

    should "set todo in description" do
      assert_match /todo/i, @generator.description
    end

    should "set target directory to the project name" do
      assert_equal @project_name, @generator.target_dir
    end

    should "set user's name from git config" do
      assert_equal @git_name, @generator.user_name
    end

    should "set email from git config" do
      assert_equal @git_email, @generator.user_email
    end

    should "set origin remote as github, based on username and project name" do
      assert_equal "git@github.com:#{@github_user}/#{@project_name}.git", @generator.git_remote
    end

    should "set homepage as github based on username and project name" do
      assert_equal "http://github.com/#{@github_user}/#{@project_name}", @generator.homepage
    end

    should "set github username from git config" do
      assert_equal @github_user, @generator.github_username
    end

    should "set project name as the-perfect-gem" do
      assert_equal @project_name, @generator.project_name
    end
  end

  context "using yard" do
    setup do
      @generator = build_generator(:documentation_framework => :yard)
    end

    should "set the doc_task to yardoc" do
      assert_equal "yardoc", @generator.doc_task
    end

  end

  context "using rdoc" do
    setup do
      @generator = build_generator(:documentation_framework => :rdoc)
    end

    should "set the doc_task to rdoc" do
      assert_equal "rdoc", @generator.doc_task
    end
  end

  context "using a custom homepage" do
    setup do
      @generator = build_generator(:homepage => 'http://zomg.com')
    end

    should "set the homepage" do
      assert_equal "http://zomg.com", @generator.homepage
    end

  end

end
