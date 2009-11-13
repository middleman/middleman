begin
  require 'spec/expectations'
  require 'spec/rake/spectask'

  desc "Run RSpec"
  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = ENV['RCOV']
    t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
    t.verbose = true
  end
rescue LoadError
  task :spec
end
