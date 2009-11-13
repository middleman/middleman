require 'rack'
require 'rack/utils'
require 'thread'

class Shotgun
  include Rack::Utils
  attr_reader :rackup_file

  def initialize(rackup_file, wrapper=nil)
    @rackup_file = rackup_file
    @wrapper = wrapper || lambda { |inner_app| inner_app }
  end

  def call(env)
    dup.call!(env)
  end

  def call!(env)
    @env = env
    @reader, @writer = IO.pipe

    # Disable GC before forking in an attempt to get some advantage
    # out of COW.
    GC.disable

    if fork
      proceed_as_parent
    else
      proceed_as_child
    end

  ensure
    GC.enable
  end

  # ==== Stuff that happens in the parent process

  def proceed_as_parent
    @writer.close
    result = Marshal.load(@reader)
    @reader.close
    Process.wait
    if result.length == 3
      result
    else
      [500, {'Content-Type'=>'text/html;charset=utf-8'}, [format_error(result)]]
    end
  end

  def format_error(result)
    message, backtrace = result
    "<h1>FAIL</h1><h3>#{escape_html(message)}</h3>" +
    "<pre>#{escape_html(backtrace.join("\n"))}</pre>"
  end

  # ==== Stuff that happens in the forked child process.

  def proceed_as_child
    @reader.close
    app = assemble_app
    status, headers, body = app.call(@env)
    Marshal.dump([status, headers.to_hash, slurp(body)], @writer)
    @writer.close
  rescue Object => boom
    Marshal.dump(["#{boom.class.name}: #{boom.to_s}", boom.backtrace], @writer)
  ensure
    exit! 0
  end

  def assemble_app
    @wrapper.call(inner_app)
  end

  def inner_app
    if rackup_file =~ /\.ru$/
      config = File.read(rackup_file)
      eval "Rack::Builder.new {( #{config}\n )}.to_app", nil, rackup_file
    else
      require rackup_file
      if defined? Sinatra::Application
        Sinatra::Application.set :reload, false
        Sinatra::Application.set :logging, false
        Sinatra::Application.set :raise_errors, true
        Sinatra::Application
      else
        Object.const_get(File.basename(rackup_file, '.rb').capitalize)
      end
    end
  end

  def slurp(body)
    return body    if body.respond_to? :to_ary
    return [body]  if body.respond_to? :to_str

    buf = []
    body.each { |part| buf << part }
    buf
  end
end
