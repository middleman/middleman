begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "fancy-buttons"
    gemspec.summary = "Make fancy buttons with the Compass stylesheet authoring framework."
    gemspec.description = "Make fancy buttons with the Compass stylesheet authoring framework."
    gemspec.email = "brandon@imathis.com"
    gemspec.homepage = "http://github.com/imathis/fancy-buttons"
    gemspec.author = "Brandon Mathis"
    gemspec.add_dependency('haml', '>= 2.2.14')
    gemspec.add_dependency('compass', '>= 0.10.0.pre2')
    gemspec.add_dependency('compass-colors', '>= 0.3.1')
    gemspec.files = []
    gemspec.files << "fancy-buttons.gemspec"
    gemspec.files << "README.markdown"
    gemspec.files << "Rakefile"
    gemspec.files << "VERSION"
    gemspec.files += Dir.glob("lib/**/*")
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
