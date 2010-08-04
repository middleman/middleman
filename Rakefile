require 'lib/middleman'
require 'rake'
require 'spec/rake/spectask'
require 'cucumber/rake/task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "middleman"
    gem.summary = %Q{A static site generator utilizing Haml, Sass and providing YUI compression and cache busting}
    gem.email = "tdreyno@gmail.com"
    gem.homepage = "http://wiki.github.com/tdreyno/middleman"
    gem.authors = ["Thomas Reynolds"]
    gem.rubyforge_project = "middleman"
    gem.executables = %w(mm-init mm-build mm-server)
    gem.add_dependency("rack")
    gem.add_dependency("thin")
    
    gem.add_dependency("shotgun", ">=0.8")
    gem.add_dependency("templater")
    gem.add_dependency("sprockets")
    gem.add_dependency("sinatra", ">=1.0")
    gem.add_dependency("sinatra-content-for")
    gem.add_dependency("rack-test")
    gem.add_dependency("yui-compressor")
    gem.add_dependency("haml", ">=3.0")
    gem.add_dependency("compass", ">=0.10")
    gem.add_dependency("fancy-buttons")
    gem.add_dependency("json_pure")
    gem.add_dependency("smusher")
    gem.add_dependency("compass-slickmap")
    
    gem.add_development_dependency("rspec")
    gem.add_development_dependency("cucumber")
    gem.add_development_dependency("jeweler")
  end
  
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Cucumber::Rake::Task.new(:cucumber, 'Run features that should pass') do |t|
  t.cucumber_opts = "--color --tags ~@wip --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
end

task :spec => :check_dependencies

task :default => [:cucumber, :spec]