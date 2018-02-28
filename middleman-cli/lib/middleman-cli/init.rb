# CLI Module
module Middleman::Cli
  # A thor task for creating new projects
  class Init < Thor::Group
    include Thor::Actions

    GIT_CMD = 'git'.freeze

    check_unknown_options!

    argument :target, type: :string, default: '.'

    class_option 'template',
                 aliases: '-T',
                 default: 'middleman/middleman-templates-default',
                 desc: 'Use a project template'

    # Do not run bundle install
    class_option 'skip-bundle',
                 type: :boolean,
                 aliases: '-B',
                 default: false,
                 desc: 'Skip bundle install'

    class_option 'bundle-path',
                 type: :string,
                 desc: 'Use specified bundle path'

    # The init task
    def init
      require 'fileutils'
      require 'tmpdir'

      unless git_present?
        msg =  'You need to install the git command line tool to initialize a new project. '
        msg << "For help installing git, please refer to GitHub's tutorial at https://help.github.com/articles/set-up-git"
        say msg, :red
        exit 1
      end

      repo_path, repo_branch = if shortname?(options[:template])
        require 'open-uri'
        require 'json'

        api = 'https://directory.middlemanapp.com/api'
        uri = ::URI.parse("#{api}/#{options[:template]}.json")

        begin
          data = ::JSON.parse(uri.read)
          is_local_dir = false
          data['links']['github'].split('#')
        rescue ::OpenURI::HTTPError
          say "Template `#{options[:template]}` not found in Middleman Directory."
          say 'Did you mean to use a full `user/repo` path?'
          exit 1
        end
      else
        repo_name, repo_branch = options[:template].split('#')
        repo_path, is_local_dir = repository_path(repo_name)
        [repo_path, repo_branch]
      end

      begin
        dir = is_local_dir ? repo_path : clone_repository(repo_path, repo_branch)

        inside(target) do
          thorfile = File.join(dir, 'Thorfile')

          if File.exist?(thorfile)
            ::Thor::Util.load_thorfile(thorfile)

            invoke 'middleman:generator'
          else
            source_paths << dir
            directory dir, '.', exclude_pattern: /\.git\/|\.gitignore$/
          end

          bundle_args = options[:'bundle-path'] ? " --path=#{options[:'bundle-path']}" : ''
          run("bundle install#{bundle_args}") unless ENV['TEST'] || options[:'skip-bundle']
        end
      ensure
        FileUtils.remove_entry(dir) if !is_local_dir && File.directory?(dir)
      end
    end

    protected

    # Copied from Bundler
    def git_present?
      return @git_present if defined?(@git_present)
      @git_present = which(GIT_CMD) || which('git.exe')
    end

    # Copied from Bundler
    def which(executable)
      if File.file?(executable) && File.executable?(executable)
        executable
      elsif ENV['PATH']
        path = ENV['PATH'].split(File::PATH_SEPARATOR).find do |p|
          abs_path = File.join(p, executable)
          File.file?(abs_path) && File.executable?(abs_path)
        end
        path && File.expand_path(executable, path)
      end
    end

    def shortname?(repo)
      repo.split('/').length == 1
    end

    def repository_path(repo_name)
      if repo_name.include?('://') || /^[^@]+@[^:]+:.+/ =~ repo_name
        repo_name
      elsif (repo_path = Pathname(repo_name)).directory? && repo_path.absolute?
        [repo_name, true]
      else
        "https://github.com/#{repo_name}.git"
      end
    end

    def clone_repository(repo_path, repo_branch)
      dir = Dir.mktmpdir

      branch_cmd = repo_branch ? "-b #{repo_branch} " : ''

      git_path = "#{branch_cmd}#{repo_path}"
      run("#{GIT_CMD} clone --depth 1 #{branch_cmd}#{repo_path} #{dir}")

      unless $?.success?
        say "Git clone command failed. Make sure git repository exists: #{git_path}", :red
        exit 1
      end

      dir
    end

    # Add to CLI
    Base.register(self, 'init', 'init TARGET [options]', 'Create new project at TARGET')

    # Map "i", "new" and "n" to "init"
    Base.map(
      'i' => 'init',
      'new' => 'init',
      'n' => 'init'
    )
  end
end
