# CLI Module
module Middleman::Cli
  # A initializing Bundler
  class Bundle < Thor
    include Thor::Actions
    check_unknown_options!

    namespace :bundle

    desc 'bundle', 'Setup initial bundle', hide: true

    # The setup task
    def bundle
      run('bundle install') # , :capture => true)
    end
  end

  # A upgrading Bundler
  class Upgrade < Thor
    include Thor::Actions
    check_unknown_options!

    namespace :upgrade

    desc 'upgrade', 'Upgrade installed bundle'

    # The upgrade task
    def upgrade
      inside(ENV['MM_ROOT']) do
        run('bundle update') # , :capture => true)
      end
    end
  end

  # Map "u" to "upgrade"
  Base.map(
    'u' => 'upgrade'
  )
end
