options = Hash.new
options[:stylesheets_directory] = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'sass'))
options[:templates_directory] = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'templates'))

Compass::Frameworks.register('slickmap', options)