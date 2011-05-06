# ===========================================================================
# Original Project:   Abbot - SproutCore Build Tools
# Copyright: ©2009 Apple Inc.
#            portions copyright @2006-2011 Strobe Inc.
#            and contributors
# ===========================================================================

begin
  require 'net/https'
  Middleman::HTTPS_ENABLED = true
rescue LoadError => e
  require 'net/http'
  Middleman::HTTPS_ENABLED = false
end

module Middleman::Features::Proxy
  class << self
    def registered(app)
      app.extend ClassMethods
      app.use Middleman::Features::Proxy::Rack
    end
    alias :included :registered
  end
  
  class Collection
    def initialize(app)
      @app = app
    end
    
    def self.proxies
      @@proxies ||= {}
    end
    
    def self.add(path, options={})
      @@proxies ||= {}
      @@proxies[path] = options[:to]
    end
  end
  
  module ClassMethods
    # Proxies requests to the path 
    #
    #     proxy '/twitter', "http://twitter/web/service"
    def proxy(path, options={})
      Middleman::Features::Proxy::Collection.add(path, options)
    end
  end
  
  # Rack application proxies requests as needed for the given project.
  module Rack

    def initialize(app)
      @app = app
    end

    def call(env)
      url = env['PATH_INFO']
      
      @proxies = Middleman::Features::Proxy::Collection.proxies
      @proxies.each do |proxy, value|
        if url.match(/^#{Regexp.escape(proxy.to_s)}/)
          return handle_proxy(value, proxy.to_s, env)
        end
      end

      return [404, {}, "not found"]
    end

    def handle_proxy(proxy, proxy_url, env)
      if proxy[:secure] && !Middleman::HTTPS_ENABLED
        $stderr.puts "~ WARNING: HTTPS is not supported on your system, using HTTP instead.\n"
        $stderr.puts"    If you are using Ubuntu, you can run `apt-get install libopenssl-ruby`\n"
        proxy[:secure] = false
      end

      origin_host = env['SERVER_NAME'] # capture the origin host for cookies
      http_method = env['REQUEST_METHOD'].to_s.downcase
      url = env['PATH_INFO']
      params = env['QUERY_STRING']

      # collect headers...
      headers = {}
      env.each do |key, value|
        next unless key =~ /^HTTP_/
        key = key.gsub(/^HTTP_/,'').downcase.sub(/^\w/){|l| l.upcase}.gsub(/_(\w)/){|l| "-#{$1.upcase}"} # remove HTTP_, dasherize and titleize
        if !key.eql? "Version"
          headers[key] = value
        end
      end

      # Rack documentation says CONTENT_TYPE and CONTENT_LENGTH aren't prefixed by HTTP_
      headers['Content-Type'] = env['CONTENT_TYPE'] if env['CONTENT_TYPE']

      length = env['CONTENT_LENGTH']
      headers['Content-Length'] = length if length

      http_host, http_port = proxy[:to].split(':')
      http_port = proxy[:secure] ? '443' : '80' if http_port.nil?

      # added 4/23/09 per Charles Jolley, corrects problem
      # when making requests to virtual hosts
      headers['Host'] = "#{http_host}:#{http_port}"

      if proxy[:url]
        url = url.sub(/^#{Regexp.escape proxy_url}/, proxy[:url])
      end

      http_path = [url]
      http_path << params if params && params.size>0
      http_path = http_path.join('?')

      response = nil
      no_body_method = %w(get copy head move options trace)

      done = false
      tries = 0
      until done
        http = ::Net::HTTP.new(http_host, http_port)

        if proxy[:secure]
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        http.start do |web|
          if no_body_method.include?(http_method)
            response = web.send(http_method, http_path, headers)
          else
            http_body = env['rack.input']
            http_body.rewind # May not be necessary but can't hurt

            req = Net::HTTPGenericRequest.new(http_method.upcase,
                                                true, true, http_path, headers)
            req.body_stream = http_body if length.to_i > 0
            response = web.request(req)
          end
        end

        status = response.code # http status code
        protocol = proxy[:secure] ? 'https' : 'http'

        $stderr.puts "~ PROXY: #{http_method.upcase} #{status} #{url} -> #{protocol}://#{http_host}:#{http_port}#{http_path}\n"

        # display and construct specific response headers
        response_headers = {}
        ignore_headers = ['transfer-encoding', 'keep-alive', 'connection']
        response.each do |key, value|
          next if ignore_headers.include?(key.downcase)
          # If this is a cookie, strip out the domain.  This technically may
          # break certain scenarios where services try to set cross-domain
          # cookies, but those services should not be doing that anyway...
          value.gsub!(/domain=[^\;]+\;? ?/,'') if key.downcase == 'set-cookie'
          # Location headers should rewrite the hostname if it is included.
          value.gsub!(/^http:\/\/#{http_host}(:[0-9]+)?\//, "http://#{http_host}/") if key.downcase == 'location'
          # content-length is returning char count not bytesize
          if key.downcase == 'content-length'
            if response.body.respond_to?(:bytesize)
              value = response.body.bytesize.to_s
            elsif response.body.respond_to?(:size)
              value = response.body.size.to_s
            else
              value = '0'
            end
          end

          $stderr.puts << "   #{key}: #{value}\n"
          response_headers[key] = value
        end

        if [301, 302, 303, 307].include?(status.to_i) && proxy[:redirect] != false
          $stderr.puts '~ REDIRECTING: '+response_headers['location']+"\n"

          uri = URI.parse(response_headers['location']);
          http_host = uri.host
          http_port = uri.port
          http_path = uri.path
          http_path += '?'+uri.query if uri.query

          tries += 1
          if tries > 10
            raise "Too many redirects!"
          end
        else
          done = true
        end
      end

      # Thin doesn't like null bodies
      response_body = response.body || ''

      return [status, ::Rack::Utils::HeaderHash.new(response_headers), [response_body]]
    end
  end
end