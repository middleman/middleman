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
