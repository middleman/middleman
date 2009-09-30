require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "middleman"
    gem.summary = %Q{A static site generator utilizing Haml and Sass}
    gem.email = "tdreyno@gmail.com"
    gem.homepage = "http://github.com/tdreyno/middleman"
    gem.authors = ["Thomas Reynolds"]
    gem.rubyforge_project = "middleman"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    gem.executables = %w(mm-init mm-build mm-server)
    gem.add_dependency("templater")
    gem.add_dependency("sprockets")
    gem.add_dependency("sinatra")
    gem.add_dependency("sinatra-content-for")
    gem.add_dependency("rack-test")
    gem.add_dependency("yui-compressor")
    gem.add_dependency("haml", ">=2.1.0")
    gem.add_dependency("chriseppstein-compass")
  end
  
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
  
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "middleman #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end