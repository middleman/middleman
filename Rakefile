require 'rubygems'  unless defined?(Gem)
# require 'fileutils' unless defined?(FileUtils)
require 'rake'
require 'yard'
# require File.expand_path("../middleman-core/lib/middleman-core/version.rb", __FILE__)

ROOT = File.expand_path(File.dirname(__FILE__))
GEM_NAME = 'middleman'

middleman_gems = %w(middleman-core middleman-more)
  
desc "Run tests for all middleman gems"
task :test do
  middleman_gems.each do |g|
    sh "cd #{File.join(ROOT, g)} && bundle exec rake test"
  end
end

desc "Run tests for all middleman gems"
task :default => :test

desc "Generate documentation"
task :doc do
  YARD::CLI::Yardoc.new.run
end