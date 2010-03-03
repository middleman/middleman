require 'sprockets'
  
class Middleman::Rack::Sprockets
  def initialize(app, options={})
    @app = app
    @options = options
  end

  def call(env)
    if env["PATH_INFO"].match(/\.js$/)
      public_file_path = File.join(Middleman::Base.public, env["PATH_INFO"])
      view_file_path   = File.join(Middleman::Base.views,  env["PATH_INFO"])
      
      source_file = Rack::File.new(Middleman::Base.public) if File.exists?(public_file_path) 
      source_file = Rack::File.new(Middleman::Base.views)  if File.exists?(view_file_path)
      
      if source_file
        status, headers, response = source_file.call(env)
        secretary = ::Sprockets::Secretary.new(@options.merge( :source_files => [ response.path ] ))
        response = secretary.concatenation.to_s
        headers["Content-Length"] = ::Rack::Utils.bytesize(response).to_s
        return [status, headers, response]
      end
    end
    
    @app.call(env)
  end
end

Middleman::Base.supported_formats << "js"

# Sprockets ruby 1.9 duckpunch
module Sprockets
  class SourceFile
    def source_lines
      @lines ||= begin
        lines = []

        comments = []
        File.open(pathname.absolute_location, 'rb') do |file|
          file.each do |line|
            lines << line = SourceLine.new(self, line, file.lineno)

            if line.begins_pdoc_comment? || comments.any?
              comments << line
            end

            if line.ends_multiline_comment?
              if line.ends_pdoc_comment?
                comments.each { |l| l.comment! }
              end
              comments.clear
            end
          end
        end

        lines
      end
    end
  end
end