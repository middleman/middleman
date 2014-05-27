# CLI Module
module Middleman::Cli
  # A thor task for creating new projects
  class Git < Thor
    include Thor::Actions
    check_unknown_options!

    namespace :git

    desc 'git REPO TARGET [options]', 'Create new project from REPO at TARGET'

    # Do not run bundle install
    method_option 'skip-bundle',
                  type: :boolean,
                  aliases: '-B',
                  default: false,
                  desc: "Don't run bundle install"

    # The git task
    # @param [String] name
    def git(repo, target='.')
      require 'rugged'
      require 'tmpdir'

      path = repository_path(repo)

      Dir.mktmpdir do |dir|
        Rugged::Repository.clone_at(path, dir)

        source_paths << dir

        directory dir, target, exclude_pattern: /\.git\/|\.gitignore$/

        inside(target) do
          run('bundle install')
        end unless ENV['TEST'] || options[:'skip-bundle']
      end
    end

    protected

    def repository_path(repo)
      "git://github.com/#{repo}.git"
    end
  end

  def self.exit_on_failure?
    true
  end

  Base.map('g' => 'git')
end
