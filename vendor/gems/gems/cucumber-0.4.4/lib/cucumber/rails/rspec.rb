require 'cucumber/rails/world'
require 'spec/expectations'
require 'spec/rails'

[Cucumber::Rails::World, ActionController::Integration::Session].each do |klass|
  klass.class_eval do
    include Spec::Matchers
    include Spec::Rails::Matchers
  end
end
