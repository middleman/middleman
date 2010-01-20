begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "compass-colors"
    gemspec.summary = "Color Support for Compass & Sass"
    gemspec.email = "chris@eppsteins.net"
    gemspec.homepage = "http://compass-style.org"
    gemspec.description = "Sass Extensions and color theme templates to make working with colors easier and more maintainable."
    gemspec.authors = ["Chris Eppstein"]
    gemspec.has_rdoc = false
    gemspec.add_dependency('compass', '>= 0.8.7')
    gemspec.files = []
    gemspec.files << "README.markdown"
    gemspec.files << "LICENSE.markdown"
    gemspec.files << "VERSION.yml"
    gemspec.files << "Rakefile"
    gemspec.files += Dir.glob("example/**/*")
    gemspec.files -= Dir.glob("example/**/*.css")
    gemspec.files -= Dir.glob("example/*/extensions/**")
    gemspec.files += Dir.glob("lib/**/*")
    gemspec.files += Dir.glob("spec/**/*")
    gemspec.files += Dir.glob("templates/**/*.*")
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
