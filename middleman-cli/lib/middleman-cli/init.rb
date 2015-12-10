# CLI Module
module Middleman::Cli
  # A thor task for creating new projects
  class Init < Thor::Group
    include Thor::Actions

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

    # The init task
    def init
      require 'fileutils'
      require 'tmpdir'

      repo_path, repo_branch = if shortname?(options[:template])
        require 'open-uri'
        require 'json'

        api = 'https://directory.middlemanapp.com/api'
        uri = ::URI.parse("#{api}/#{options[:template]}.json")

        begin
          data = ::JSON.parse(uri.read)
          data['links']['github']
          data['links']['github'].split('#')
        rescue ::OpenURI::HTTPError
          say "Template `#{options[:template]}` not found in Middleman Directory."
          say 'Did you mean to use a full `user/repo` path?'
          exit
        end
      else
        repo_name, repo_branch = options[:template].split('#')
        [repository_path(repo_name), repo_branch]
      end

      dir = Dir.mktmpdir

      begin
        branch_cmd = repo_branch ? "-b #{repo_branch} " : ''

        run("git clone --depth 1 #{branch_cmd}#{repo_path} #{dir}")

        unless File.directory?(dir)
          say 'Git clone failed, maybe the url is invalid or you don\'t have the permissions?', :red
          exit
        end

        inside(target) do
          thorfile = File.join(dir, 'Thorfile')

          if File.exist?(thorfile)
            ::Thor::Util.load_thorfile(thorfile)

            invoke 'middleman:generator'
          else
            source_paths << dir
            directory dir, '.', exclude_pattern: /\.git\/|\.gitignore$/
          end

          run('bundle install') unless ENV['TEST'] || options[:'skip-bundle']
        end
      ensure
        FileUtils.remove_entry(dir) if File.directory?(dir)
      end
    end

    protected

    def shortname?(repo)
      repo.split('/').length == 1
    end

    def repository_path(repo)
      repo.include?('://') || repo.include?('git@') ? repo : "git://github.com/#{repo}.git"
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
