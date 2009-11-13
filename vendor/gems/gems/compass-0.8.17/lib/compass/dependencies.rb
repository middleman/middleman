unless defined?(Sass)
  require 'rubygems'
  begin
    gem 'haml-edge', '>= 2.3.0'
    $stderr.puts "Loading haml-edge gem."
  rescue Exception
    #pass
  end
  require 'sass'
end