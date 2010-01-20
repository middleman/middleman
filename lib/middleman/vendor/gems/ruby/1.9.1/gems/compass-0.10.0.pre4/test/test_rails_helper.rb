# XXX This file isn't in use at the moment, but will be used to help test
# XXX deep rails integration of compass features.
need_gems = false

# allows testing with edge Rails by creating a test/rails symlink
RAILS_ROOT = linked_rails = File.dirname(__FILE__) + '/rails'
RAILS_ENV = 'test'

if File.exists?(linked_rails) && !$:.include?(linked_rails + '/activesupport/lib')
  puts "[ using linked Rails ]"
  $:.unshift linked_rails + '/activesupport/lib'
  $:.unshift linked_rails + '/actionpack/lib'
else
  need_gems = true
end

require 'rubygems' if need_gems

require 'action_controller'
require 'action_view'
