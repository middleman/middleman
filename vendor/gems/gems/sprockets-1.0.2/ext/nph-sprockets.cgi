#!/usr/bin/env ruby

# This is a simple CGI wrapper around Sprockets. 
#
# Copy it into a directory on your site with CGI enabled. When invoked, the 
# script will search its directory and parent directories for a YAML file named
# "config/sprockets.yml" in order to load configuration information.
#
# If you set the environment variable "sprockets_generate_output_file" to 
# "true" the concatenation will be cached to disk. Use it in conjunction with 
# URL rewriting to cache your Sprockets output on the first request.
#
# Assuming a site layout like this:
#
#     mysite/
#       config/
#         sprockets.yml
#       javascripts/
#         mysite.js
#         ...
#       public/
#         index.html
#         nph-sprockets.cgi (this file)
#       vendor/
#         sprockets/
#           prototype/ -> ...
#           scriptaculous/ -> ...
#
# mysite/config/sprockets.yml might look like this:
#
#     :load_path:
#       - javascripts
#       - vendor/sprockets/*/src
#     :source_files:
#       - javascripts/mysite.js
#       - javascripts/*.js
#     :output_file: public/sprockets.js
#
# The <script> tag in mysite/public/index.html could look like this:
#
#     <script type="text/javascript" src="/sprockets.js"></script>
#
# And you might have the following Apache configuration:
#
#     <VirtualHost ...>
#       ServerName mysite.example.org
#       DocumentRoot "/path/to/mysite/public"
#
#       <Directory "/path/to/mysite/public">
#         Options +ExecCGI +FollowSymLinks
#         AddHandler cgi-script .cgi
#         
#         RewriteEngine on
#         RewriteCond /sprockets.js !-f
#         RewriteRule ^sprockets\.js /nph-sprockets.cgi [P,L]
#       </Directory>
#     </VirtualHost>
#
# All requests to /sprockets.js will transparently proxy /nph-sprockets.cgi if
# mysite/public/sprockets.js does not exist. In production, you can add
#
#     SetEnv sprockets_generate_output_file true
#
# to your Apache configuration and mysites/public/sprockets.js will be cached
# on the first request to /sprockets.js.

require "yaml"
require "fileutils"

def respond_with(options = {})
  options = { :code => 200, :content => "", :type => "text/plain" }.merge(options)
  print "HTTP/1.0 #{options[:code]}\r\n"
  print "Content-Type: #{options[:type]}\r\n"
  print "Content-Length: #{options[:content].length}\r\n"
  print "\r\n#{options[:content]}"
  $stdout.flush
  exit!
end

def search_upwards_for(filename)
  pwd = original_pwd = Dir.pwd
  loop do
    return File.expand_path(filename) if File.file?(filename)
    Dir.chdir("..")
    respond_with(:code => 500, :content => "couldn't find config/sprockets.yml") if Dir.pwd == pwd
    pwd = Dir.pwd
  end
ensure
  Dir.chdir(original_pwd)
end

def generate_output_file?
  (ENV["REDIRECT_sprockets_generate_output_file"] || ENV["sprockets_generate_output_file"]) =~ /true/i
end

configuration_file = search_upwards_for("config/sprockets.yml")
sprockets_root     = File.dirname(File.dirname(configuration_file))
configuration      = YAML.load(IO.read(configuration_file))

begin
  if File.directory?(sprockets_dir = File.join(sprockets_root, "vendor/gems/sprockets/lib"))
    $:.unshift sprockets_dir
  elsif File.directory?(sprockets_dir = File.join(sprockets_root, "vendor/sprockets/lib"))
    $:.unshift sprockets_dir
  else
    require "rubygems"
  end
  
  require "sprockets"
  
rescue Exception => e
  respond_with(:code => 500, :content => "couldn't find sprockets: #{e}")
end

begin
  secretary = Sprockets::Secretary.new(
    :root         => sprockets_root,
    :load_path    => configuration[:load_path],
    :source_files => configuration[:source_files]
  )
  
  secretary.concatenation.save_to(File.join(sprockets_root, configuration[:output_file])) if generate_output_file?
  respond_with(:content => secretary.concatenation.to_s, :type => "text/javascript")
  
rescue Exception => e
  respond_with(:code => 500, :content => "couldn't generate concatenated javascript: #{e}")
end
