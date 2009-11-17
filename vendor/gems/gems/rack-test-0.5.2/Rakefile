require "rubygems"

begin
  require "spec/rake/spectask"
rescue LoadError
  desc "Run specs"
  task(:spec) { $stderr.puts '`gem install rspec` to run specs' }
else
  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
    t.libs << 'lib'
    t.libs << 'spec'
    t.warning = true
  end

  task :default => :spec

  desc "Run all specs in spec directory with RCov"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
    t.libs << 'lib'
    t.libs << 'spec'
    t.warning = true
    t.rcov = true
    t.rcov_opts = ['-x spec']
  end
end

desc "Generate RDoc"
task :docs do
  FileUtils.rm_rf("doc")
  require "rack/test"
  system "hanna --title 'Rack::Test #{Rack::Test::VERSION} API Documentation'"
end

desc 'Removes trailing whitespace'
task :whitespace do
  sh %{find . -name '*.rb' -exec sed -i '' 's/ *$//g' {} \\;}
end
