require 'aruba/cucumber'
require 'middleman-core/step_definitions/middleman_steps'
require 'middleman-core/step_definitions/builder_steps'
require 'middleman-core/step_definitions/server_steps'
require 'middleman-core/step_definitions/commandline_steps'

# Monkeypatch for windows support
module ArubaMonkeypatch
  def detect_ruby(cmd)
    if cmd.start_with?('middleman ') && Gem.win_platform?
      "#{current_ruby} #{Dir.pwd}/../middleman-cli/bin/#{cmd}"
    else
      cmd.sub(/^ruby(?= )/, current_ruby)
    end
  end
end
World(ArubaMonkeypatch)

Before do
  @aruba_timeout_seconds = RUBY_PLATFORM == 'java' ? 120 : 60
end

# This is for making the tests work - since the tests
# don't completely reload middleman, I18n.load_path can get
# polluted with paths from other test app directories that don't
# exist anymore.
After do
  if defined?(I18n)
    I18n.load_path.delete_if { |path| path =~ %r{tmp/aruba} }
    I18n.reload!
  end
end
