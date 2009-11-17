if defined?(ActiveRecord::Base)
  require 'test_help' 
else
  require 'action_controller/test_process'
  require 'action_controller/integration'
end

require 'cucumber/rails/test_unit'
require 'cucumber/rails/action_controller'

if ::Rails.respond_to?(:configuration) && !(::Rails.configuration.cache_classes)
  warn "WARNING: You have set Rails' config.cache_classes to false (most likely in config/environments/cucumber.rb).  This setting is known to break Cucumber's use_transactional_fixtures method. Set config.cache_classes to true if you want to use transactional fixtures.  For more information see https://rspec.lighthouseapp.com/projects/16211/tickets/165."
end

module Cucumber #:nodoc:
  module Rails
    class World < ActionController::IntegrationTest
      include ActiveSupport::Testing::SetupAndTeardown
      def initialize #:nodoc:
        @_result = Test::Unit::TestResult.new
      end
    end
  end
end

require 'cucumber/rails/active_record'

World do
  Cucumber::Rails::World.new
end
