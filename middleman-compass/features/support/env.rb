PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
ENV['TEST'] = 'true'
require "middleman-core"
require "middleman-core/step_definitions"
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman-compass')
require "erubis"

