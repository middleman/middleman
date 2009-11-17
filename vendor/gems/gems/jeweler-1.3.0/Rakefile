require 'rake'

$LOAD_PATH.unshift('lib')

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "jeweler"
  gem.summary = "Simple and opinionated helper for creating Rubygem projects on GitHub"
  gem.email = "josh@technicalpickles.com"
  gem.homepage = "http://github.com/technicalpickles/jeweler"
  gem.description = "Simple and opinionated helper for creating Rubygem projects on GitHub"
  gem.authors = ["Josh Nichols"]
  gem.files.include %w(lib/jeweler/templates/.document lib/jeweler/templates/.gitignore)

  gem.add_dependency "git", ">= 1.2.5"
  gem.add_dependency "rubyforge", ">= 2.0.0"
  gem.add_dependency "gemcutter", ">= 0.1.0"

  gem.rubyforge_project = "pickles"

  gem.add_development_dependency "thoughtbot-shoulda"
  gem.add_development_dependency "mhennemeyer-output_catcher"
  gem.add_development_dependency "rr"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "redgreen"
end

Jeweler::GemcutterTasks.new

Jeweler::RubyforgeTasks.new do |t|
  t.doc_task = :yardoc
end


require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.test_files = FileList.new('test/**/test_*.rb') do |list|
    list.exclude 'test/test_helper.rb'
  end
  test.libs << 'test'
  test.verbose = true
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:yardoc) do |t|
    t.files   = FileList['lib/**/*.rb'].exclude('lib/jeweler/templates/**/*.rb')
  end
rescue LoadError
  task :yardoc do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end


begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new(:rcov) do |rcov|
    rcov.libs << 'test'
    rcov.pattern = 'test/**/test_*.rb'
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features) do |features|
    features.cucumber_opts = "features --format progress"
  end
  namespace :features do
    Cucumber::Rake::Task.new(:pretty) do |features|
      features.cucumber_opts = "features --format progress"
    end
  end
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
  namespace :features do
    task :pretty do
      abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
    end
  end
end

if ENV["RUN_CODE_RUN"] == "true"
  task :default => [:test, :features]
else
  task :default => :test
end


task :test => :check_dependencies
task :features => :check_dependencies
