# HTTPClient - HTTP client library.
# Copyright (C) 2000-2009  NAKAMURA, Hiroshi  <nahi@ruby-lang.org>.
#
# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'uri'
require 'stringio'
require 'digest/sha1'

# Extra library
require 'httpclient/util'
require 'httpclient/ssl_config'
require 'httpclient/connection'
require 'httpclient/session'
require 'httpclient/http'
require 'httpclient/auth'
require 'httpclient/cookie'


# The HTTPClient class provides several methods for accessing Web resources
# via HTTP.
#
# HTTPClient instance is designed to be MT-safe.  You can call a HTTPClient
# instance from several threads without synchronization after setting up an
# instance.
#
#   clnt = HTTPClient.new
#   clnt.set_cookie_store('/home/nahi/cookie.dat')
#   urls.each do |url|
#     Thread.new(url) do |u|
#       p clnt.head(u).status
#     end
#   end
#
# == How to use
#
# At first, how to create your client.  See initialize for more detail.
#
# 1. Create simple client.
#
#     clnt = HTTPClient.new
#
# 2. Accessing resources through HTTP proxy.  You can use environment
#    variable 'http_proxy' or 'HTTP_PROXY' instead.
#
#     clnt = HTTPClient.new('http://myproxy:8080')
#
# === How to retrieve web resources
#
# See get_content.
#
# 1. Get content of specified URL.  It returns a String of whole result.
#
#     puts clnt.get_content('http://dev.ctor.org/')
#
# 2. Get content as chunks of String.  It yields chunks of String.
#
#     clnt.get_content('http://dev.ctor.org/') do |chunk|
#       puts chunk
#     end
#
# === Invoking other HTTP methods
#
# See head, get, post, put, delete, options, propfind, proppatch and trace.  
# It returns a HTTP::Message instance as a response.
#
# 1. Do HEAD request.
#
#     res = clnt.head(uri)
#     p res.header['Last-Modified'][0]
#
# 2. Do GET request with query.
#
#     query = { 'keyword' => 'ruby', 'lang' => 'en' }
#     res = clnt.get(uri, query)
#     p res.status
#     p res.contenttype
#     p res.header['X-Custom']
#     puts res.content
#
# === How to POST
#
# See post.
#
# 1. Do POST a form data.
#
#     body = { 'keyword' => 'ruby', 'lang' => 'en' }
#     res = clnt.post(uri, body)
#
# 2. Do multipart file upload with POST.  No need to set extra header by
#    yourself from httpclient/2.1.4.
#
#     File.open('/tmp/post_data') do |file|
#       body = { 'upload' => file, 'user' => 'nahi' }
#       res = clnt.post(uri, body)
#     end
#
# === Accessing via SSL
#
# Ruby needs to be compiled with OpenSSL.
#
# 1. Get content of specified URL via SSL.
#    Just pass an URL which starts with 'https://'.
#
#     https_url = 'https://www.rsa.com'
#     clnt.get_content(https_url)
#
# 2. Getting peer certificate from response.
#
#     res = clnt.get(https_url)
#     p res.peer_cert #=> returns OpenSSL::X509::Certificate
#
# 3. Configuring OpenSSL options.  See HTTPClient::SSLConfig for more details.
#
#     user_cert_file = 'cert.pem'
#     user_key_file = 'privkey.pem'
#     clnt.ssl_config.set_client_cert_file(user_cert_file, user_key_file)
#     clnt.get_content(https_url)
#
# === Handling Cookies
#
# 1. Using volatile Cookies.  Nothing to do.  HTTPClient handles Cookies.
#
#     clnt = HTTPClient.new
#     clnt.get_content(url1) # receives Cookies.
#     clnt.get_content(url2) # sends Cookies if needed.
#
# 2. Saving non volatile Cookies to a specified file.  Need to set a file at
#    first and invoke save method at last.
#
#     clnt = HTTPClient.new
#     clnt.set_cookie_store('/home/nahi/cookie.dat')
#     clnt.get_content(url)
#     ...
#     clnt.save_cookie_store
#
# 3. Disabling Cookies.
#
#     clnt = HTTPClient.new
#     clnt.cookie_manager = nil
#
# === Configuring authentication credentials
#
# 1. Authentication with Web server.  Supports BasicAuth, DigestAuth, and
#    Negotiate/NTLM (requires ruby/ntlm module).
#
#     clnt = HTTPClient.new
#     domain = 'http://dev.ctor.org/http-access2/'
#     user = 'user'
#     password = 'user'
#     clnt.set_auth(domain, user, password)
#     p clnt.get_content('http://dev.ctor.org/http-access2/login').status
#
# 2. Authentication with Proxy server.  Supports BasicAuth and NTLM
#    (requires win32/sspi)
#
#     clnt = HTTPClient.new(proxy)
#     user = 'proxy'
#     password = 'proxy'
#     clnt.set_proxy_auth(user, password)
#     p clnt.get_content(url)
#
# === Invoking HTTP methods with custom header
#
# Pass a Hash or an Array for extheader argument.
#
#     extheader = { 'Accept' => '*/*' }
#     clnt.get_content(uri, query, extheader)
#
#     extheader = [['Accept', 'image/jpeg'], ['Accept', 'image/png']]
#     clnt.get_content(uri, query, extheader)
#
# === Invoking HTTP methods asynchronously
#
# See head_async, get_async, post_async, put_async, delete_async,
# options_async, propfind_async, proppatch_async, and trace_async.
# It immediately returns a HTTPClient::Connection instance as a returning value.
#
#     connection = clnt.post_async(url, body)
#     print 'posting.'
#     while true
#       break if connection.finished?
#       print '.'
#       sleep 1
#     end
#     puts '.'
#     res = connection.pop
#     p res.status
#     p res.content.read # res.content is an IO for the res of async method.
#
# === Shortcut methods
#
# You can invoke get_content, get, etc. without creating HTTPClient instance.
#
#   ruby -rhttpclient -e 'puts HTTPClient.get_content(ARGV.shift)' http://dev.ctor.org/
#   ruby -rhttpclient -e 'p HTTPClient.head(ARGV.shift).header["last-modified"]' http://dev.ctor.org/
#
class HTTPClient
  VERSION = '2.1.5'
  RUBY_VERSION_STRING = "ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  /: (\S+) (\S+)/ =~ %q$Id: httpclient.rb 280 2009-06-02 15:44:28Z nahi $
  LIB_NAME = "(#{$1}/#{$2}, #{RUBY_VERSION_STRING})"

  include Util

  # Raised for indicating running environment configuration error for example
  # accessing via SSL under the ruby which is not compiled with OpenSSL.
  class ConfigurationError < StandardError
  end

  # Raised for indicating HTTP response error.
  class BadResponseError < RuntimeError
    # HTTP::Message:: a response
    attr_reader :res

    def initialize(msg, res = nil) # :nodoc:
      super(msg)
      @res = res
    end
  end

  # Raised for indicating a timeout error.
  class TimeoutError < RuntimeError
  end

  # Raised for indicating a connection timeout error.
  # You can configure connection timeout via HTTPClient#connect_timeout=.
  class ConnectTimeoutError < TimeoutError
  end

  # Raised for indicating a request sending timeout error.
  # You can configure request sending timeout via HTTPClient#send_timeout=.
  class SendTimeoutError < TimeoutError
  end

  # Raised for indicating a response receiving timeout error.
  # You can configure response receiving timeout via
  # HTTPClient#receive_timeout=.
  class ReceiveTimeoutError < TimeoutError
  end

  # Deprecated.  just for backward compatibility
  class Session
    BadResponse = ::HTTPClient::BadResponseError
  end

  class << self
    %w(get_content post_content head get post put delete options propfind proppatch trace).each do |name|
      eval <<-EOD
        def #{name}(*arg, &block)
          clnt = new
          begin
            clnt.#{name}(*arg, &block)
          ensure
            clnt.reset_all
          end
        end
      EOD
    end

  private

    def attr_proxy(symbol, assignable = false)
      name = symbol.to_s
      define_method(name) {
        @session_manager.__send__(name)
      }
      if assignable
        aname = name + '='
        define_method(aname) { |rhs|
          reset_all
          @session_manager.__send__(aname, rhs)
        }
      end
    end
  end

  # HTTPClient::SSLConfig:: SSL configurator.
  attr_reader :ssl_config
  # WebAgent::CookieManager:: Cookies configurator.
  attr_accessor :cookie_manager
  # An array of response HTTP message body String which is used for loop-back
  # test.  See test/* to see how to use it.  If you want to do loop-back test
  # of HTTP header, use test_loopback_http_response instead.
  attr_reader :test_loopback_response
  # An array of request filter which can trap HTTP request/response.
  # See HTTPClient::WWWAuth to see how to use it.
  attr_reader :request_filter
  # HTTPClient::ProxyAuth:: Proxy authentication handler.
  attr_reader :proxy_auth
  # HTTPClient::WWWAuth:: WWW authentication handler.
  attr_reader :www_auth
  # How many times get_content and post_content follows HTTP redirect.
  # 10 by default.
  attr_accessor :follow_redirect_count

  # Set HTTP version as a String:: 'HTTP/1.0' or 'HTTP/1.1'
  attr_proxy(:protocol_version, true)
  # Connect timeout in sec.
  attr_proxy(:connect_timeout, true)
  # Request sending timeout in sec.
  attr_proxy(:send_timeout, true)
  # Response receiving timeout in sec.
  attr_proxy(:receive_timeout, true)
  # Negotiation retry count for authentication.  5 by default.
  attr_proxy(:protocol_retry_count, true)
  # if your ruby is older than 2005-09-06, do not set socket_sync = false to
  # avoid an SSL socket blocking bug in openssl/buffering.rb.
  attr_proxy(:socket_sync, true)
  # User-Agent header in HTTP request.
  attr_proxy(:agent_name, true)
  # From header in HTTP request.
  attr_proxy(:from, true)
  # An array of response HTTP String (not a HTTP message body) which is used
  # for loopback test.  See test/* to see how to use it.
  attr_proxy(:test_loopback_http_response)

  # Default extheader for PROPFIND request.
  PROPFIND_DEFAULT_EXTHEADER = { 'Depth' => '0' }

  # Creates a HTTPClient instance which manages sessions, cookies, etc.
  #
  # HTTPClient.new takes 3 optional arguments for proxy url string,
  # User-Agent String and From header String.  User-Agent and From are embedded
  # in HTTP request Header if given.  No User-Agent and From header added
  # without setting it explicitly.
  #
  #   proxy = 'http://myproxy:8080'
  #   agent_name = 'MyAgent/0.1'
  #   from = 'from@example.com'
  #   HTTPClient.new(proxy, agent_name, from)
  #
  # You can use a keyword argument style Hash.  Keys are :proxy, :agent_name
  # and :from.
  #
  #   HTTPClient.new(:agent_name = 'MyAgent/0.1')
  def initialize(*args)
    proxy, agent_name, from = keyword_argument(args, :proxy, :agent_name, :from)
    @proxy = nil        # assigned later.
    @no_proxy = nil
    @www_auth = WWWAuth.new
    @proxy_auth = ProxyAuth.new
    @request_filter = [@proxy_auth, @www_auth]
    @debug_dev = nil
    @redirect_uri_callback = method(:default_redirect_uri_callback)
    @test_loopback_response = []
    @session_manager = SessionManager.new(self)
    @session_manager.agent_name = agent_name
    @session_manager.from = from
    @session_manager.ssl_config = @ssl_config = SSLConfig.new(self)
    @cookie_manager = WebAgent::CookieManager.new
    @follow_redirect_count = 10
    load_environment
    self.proxy = proxy if proxy
  end

  # Returns debug device if exists.  See debug_dev=.
  def debug_dev
    @debug_dev
  end

  # Sets debug device.  Once debug device is set, all HTTP requests and
  # responses are dumped to given device.  dev must respond to << for dump.
  #
  # Calling this method resets all existing sessions.
  def debug_dev=(dev)
    @debug_dev = dev
    reset_all
    @session_manager.debug_dev = dev
  end

  # Returns URI object of HTTP proxy if exists.
  def proxy
    @proxy
  end

  # Sets HTTP proxy used for HTTP connection.  Given proxy can be an URI,
  # a String or nil.  You can set user/password for proxy authentication like
  # HTTPClient#proxy = 'http://user:passwd@myproxy:8080'
  #
  # You can use environment variable 'http_proxy' or 'HTTP_PROXY' for it.
  # You need to use 'cgi_http_proxy' or 'CGI_HTTP_PROXY' instead if you run
  # HTTPClient from CGI environment from security reason. (HTTPClient checks
  # 'REQUEST_METHOD' environment variable whether it's CGI or not)
  #
  # Calling this method resets all existing sessions.
  def proxy=(proxy)
    if proxy.nil?
      @proxy = nil
      @proxy_auth.reset_challenge
    else
      @proxy = urify(proxy)
      if @proxy.scheme == nil or @proxy.scheme.downcase != 'http' or
          @proxy.host == nil or @proxy.port == nil
        raise ArgumentError.new("unsupported proxy #{proxy}")
      end
      @proxy_auth.reset_challenge
      if @proxy.user || @proxy.password
        @proxy_auth.set_auth(@proxy.user, @proxy.password)
      end
    end
    reset_all
    @session_manager.proxy = @proxy
    @proxy
  end

  # Returns NO_PROXY setting String if given.
  def no_proxy
    @no_proxy
  end

  # Sets NO_PROXY setting String.  no_proxy must be a comma separated String.
  # Each entry must be 'host' or 'host:port' such as;
  # HTTPClient#no_proxy = 'example.com,example.co.jp:443'
  #
  # 'localhost' is treated as a no_proxy site regardless of explicitly listed.
  # HTTPClient checks given URI objects before accessing it.
  # 'host' is tail string match.  No IP-addr conversion.
  #
  # You can use environment variable 'no_proxy' or 'NO_PROXY' for it.
  #
  # Calling this method resets all existing sessions.
  def no_proxy=(no_proxy)
    @no_proxy = no_proxy
    reset_all
  end

  # Sets credential for Web server authentication.
  # domain:: a String or an URI to specify where HTTPClient should use this
  #       credential.  If you set uri to nil, HTTPClient uses this credential
  #       wherever a server requires it.
  # user:: username String.
  # passwd:: password String.
  #
  # You can set multiple credentials for each uri.
  #
  #   clnt.set_auth('http://www.example.com/foo/', 'foo_user', 'passwd')
  #   clnt.set_auth('http://www.example.com/bar/', 'bar_user', 'passwd')
  #
  # Calling this method resets all existing sessions.
  def set_auth(domain, user, passwd)
    uri = urify(domain)
    @www_auth.set_auth(uri, user, passwd)
    reset_all
  end

  # Deprecated.  Use set_auth instead.
  def set_basic_auth(domain, user, passwd)
    uri = urify(domain)
    @www_auth.basic_auth.set(uri, user, passwd)
    reset_all
  end

  # Sets credential for Proxy authentication.
  # user:: username String.
  # passwd:: password String.
  #
  # Calling this method resets all existing sessions.
  def set_proxy_auth(user, passwd)
    @proxy_auth.set_auth(user, passwd)
    reset_all
  end

  # Sets the filename where non-volatile Cookies be saved by calling
  # save_cookie_store.
  # This method tries to load and managing Cookies from the specified file.
  #
  # Calling this method resets all existing sessions.
  def set_cookie_store(filename)
    @cookie_manager.cookies_file = filename
    @cookie_manager.load_cookies if filename
    reset_all
  end

  # Try to save Cookies to the file specified in set_cookie_store.  Unexpected
  # error will be raised if you don't call set_cookie_store first.
  # (interface mismatch between WebAgent::CookieManager implementation)
  def save_cookie_store
    @cookie_manager.save_cookies
  end

  # Sets callback proc when HTTP redirect status is returned for get_content
  # and post_content.  default_redirect_uri_callback is used by default.
  #
  # If you need strict implementation which does not allow relative URI
  # redirection, set strict_redirect_uri_callback instead.
  #
  #   clnt.redirect_uri_callback = clnt.method(:strict_redirect_uri_callback)
  #
  def redirect_uri_callback=(redirect_uri_callback)
    @redirect_uri_callback = redirect_uri_callback
  end

  # Retrieves a web resource.
  #
  # uri:: a String or an URI object which represents an URL of web resource.
  # query:: a Hash or an Array of query part of URL.
  #         e.g. { "a" => "b" } => 'http://host/part?a=b'.
  #         Give an array to pass multiple value like
  #         [["a", "b"], ["a", "c"]] => 'http://host/part?a=b&a=c'.
  # extheader:: a Hash or an Array of extra headers.  e.g.
  #             { 'Accept' => '*/*' } or
  #             [['Accept', 'image/jpeg'], ['Accept', 'image/png']].
  # &block:: Give a block to get chunked message-body of response like
  #          get_content(uri) { |chunked_body| ... }.
  #          Size of each chunk may not be the same.
  #
  # get_content follows HTTP redirect status (see HTTP::Status.redirect?)
  # internally and try to retrieve content from redirected URL.  See
  # redirect_uri_callback= how HTTP redirection is handled.
  #
  # If you need to get full HTTP response including HTTP status and headers,
  # use get method.  get returns HTTP::Message as a response and you need to
  # follow HTTP redirect by yourself if you need.
  def get_content(uri, query = nil, extheader = {}, &block)
    follow_redirect(:get, uri, query, nil, extheader, &block).content
  end

  # Posts a content.
  #
  # uri:: a String or an URI object which represents an URL of web resource.
  # body:: a Hash or an Array of body part.
  #        e.g. { "a" => "b" } => 'a=b'.
  #        Give an array to pass multiple value like
  #        [["a", "b"], ["a", "c"]] => 'a=b&a=c'.
  #        When you pass a File as a value, it will be posted as a
  #        multipart/form-data.  e.g. { 'upload' => file }
  # extheader:: a Hash or an Array of extra headers.  e.g.
  #             { 'Accept' => '*/*' } or
  #             [['Accept', 'image/jpeg'], ['Accept', 'image/png']].
  # &block:: Give a block to get chunked message-body of response like
  #          post_content(uri) { |chunked_body| ... }.
  #          Size of each chunk may not be the same.
  #
  # post_content follows HTTP redirect status (see HTTP::Status.redirect?)
  # internally and try to post the content to redirected URL.  See
  # redirect_uri_callback= how HTTP redirection is handled.
  #
  # If you need to get full HTTP response including HTTP status and headers,
  # use post method.
  def post_content(uri, body = nil, extheader = {}, &block)
    follow_redirect(:post, uri, nil, body, extheader, &block).content
  end

  # A method for redirect uri callback.  How to use:
  #   clnt.redirect_uri_callback = clnt.method(:strict_redirect_uri_callback)
  # This callback does not allow relative redirect such as
  #   Location: ../foo/
  # in HTTP header. (raises BadResponseError instead)
  def strict_redirect_uri_callback(uri, res)
    newuri = URI.parse(res.header['location'][0])
    if https?(uri) && !https?(newuri)
      raise BadResponseError.new("redirecting to non-https resource")
    end
    unless newuri.is_a?(URI::HTTP)
      raise BadResponseError.new("unexpected location: #{newuri}", res)
    end
    puts "redirect to: #{newuri}" if $DEBUG
    newuri
  end

  # A default method for redirect uri callback.  This method is used by
  # HTTPClient instance by default.
  # This callback allows relative redirect such as
  #   Location: ../foo/
  # in HTTP header.
  def default_redirect_uri_callback(uri, res)
    newuri = URI.parse(res.header['location'][0])
    if https?(uri) && !https?(newuri)
      raise BadResponseError.new("redirecting to non-https resource")
    end
    unless newuri.is_a?(URI::HTTP)
      newuri = uri + newuri
      STDERR.puts("could be a relative URI in location header which is not recommended")
      STDERR.puts("'The field value consists of a single absolute URI' in HTTP spec")
    end
    puts "redirect to: #{newuri}" if $DEBUG
    newuri
  end

  # Sends HEAD request to the specified URL.  See request for arguments.
  def head(uri, query = nil, extheader = {})
    request(:head, uri, query, nil, extheader)
  end

  # Sends GET request to the specified URL.  See request for arguments.
  def get(uri, query = nil, extheader = {}, &block)
    request(:get, uri, query, nil, extheader, &block)
  end

  # Sends POST request to the specified URL.  See request for arguments.
  def post(uri, body = '', extheader = {}, &block)
    request(:post, uri, nil, body, extheader, &block)
  end

  # Sends PUT request to the specified URL.  See request for arguments.
  def put(uri, body = '', extheader = {}, &block)
    request(:put, uri, nil, body, extheader, &block)
  end

  # Sends DELETE request to the specified URL.  See request for arguments.
  def delete(uri, extheader = {}, &block)
    request(:delete, uri, nil, nil, extheader, &block)
  end

  # Sends OPTIONS request to the specified URL.  See request for arguments.
  def options(uri, extheader = {}, &block)
    request(:options, uri, nil, nil, extheader, &block)
  end

  # Sends PROPFIND request to the specified URL.  See request for arguments.
  def propfind(uri, extheader = PROPFIND_DEFAULT_EXTHEADER, &block)
    request(:propfind, uri, nil, nil, extheader, &block)
  end
  
  # Sends PROPPATCH request to the specified URL.  See request for arguments.
  def proppatch(uri, body = nil, extheader = {}, &block)
    request(:proppatch, uri, nil, body, extheader, &block)
  end
  
  # Sends TRACE request to the specified URL.  See request for arguments.
  def trace(uri, query = nil, body = nil, extheader = {}, &block)
    request('TRACE', uri, query, body, extheader, &block)
  end

  # Sends a request to the specified URL.
  #
  # method:: HTTP method to be sent.  method.to_s.upcase is used.
  # uri:: a String or an URI object which represents an URL of web resource.
  # query:: a Hash or an Array of query part of URL.
  #         e.g. { "a" => "b" } => 'http://host/part?a=b'
  #         Give an array to pass multiple value like
  #         [["a", "b"], ["a", "c"]] => 'http://host/part?a=b&a=c'
  # body:: a Hash or an Array of body part.
  #        e.g. { "a" => "b" } => 'a=b'.
  #        Give an array to pass multiple value like
  #        [["a", "b"], ["a", "c"]] => 'a=b&a=c'.
  #        When the given method is 'POST' and the given body contains a file
  #        as a value, it will be posted as a multipart/form-data.
  #        e.g. { 'upload' => file }
  #        See HTTP::Message.file? for actual condition of 'a file'.
  # extheader:: a Hash or an Array of extra headers.  e.g.
  #             { 'Accept' => '*/*' } or
  #             [['Accept', 'image/jpeg'], ['Accept', 'image/png']].
  # &block:: Give a block to get chunked message-body of response like
  #          get(uri) { |chunked_body| ... }.
  #          Size of each chunk may not be the same.
  #
  # You can also pass a String as a body.  HTTPClient just sends a String as
  # a HTTP request message body.
  #
  # When you pass an IO as a body, HTTPClient sends it as a HTTP request with
  # chunked encoding (Transfer-Encoding: chunked in HTTP header).  Bear in mind
  # that some server application does not support chunked request.  At least
  # cgi.rb does not support it.
  def request(method, uri, query = nil, body = nil, extheader = {}, &block)
    uri = urify(uri)
    if block
      filtered_block = proc { |res, str|
        block.call(str)
      }
    end
    do_request(method, uri, query, body, extheader, &filtered_block)
  end

  # Sends HEAD request in async style.  See request_async for arguments.
  # It immediately returns a HTTPClient::Connection instance as a result.
  def head_async(uri, query = nil, extheader = {})
    request_async(:head, uri, query, nil, extheader)
  end

  # Sends GET request in async style.  See request_async for arguments.
  # It immediately returns a HTTPClient::Connection instance as a result.
  def get_async(uri, query = nil, extheader = {})
    request_async(:get, uri, query, nil, extheader)
  end

  # Sends POST request in async style.  See request_async for arguments.
  # It immediately returns a HTTPClient::Connection instance as a result.
  def post_async(uri, body = nil, extheader = {})
    request_async(:post, uri, nil, body, extheader)
  end

  # Sends PUT request in async style.  See request_async for arguments.
  # It immediately returns a HTTPClient::Connection instance as a result.
  def put_async(uri, body = nil, extheader = {})
    request_async(:put, uri, nil, body, extheader)
  end

  # Sends DELETE request in async style.  See request_async for arguments.
  # It immediately returns a HTTPClient::Connection instance as a result.
  def delete_async(uri, extheader = {})
    request_async(:delete, uri, nil, nil, extheader)
  end

  # Sends OPTIONS request in async style.  See request_async for arguments.
  # It immediately returns a HTTPClient::Connection instance as a result.
  def options_async(uri, extheader = {})
    request_async(:options, uri, nil, nil, extheader)
  end

  # Sends PROPFIND request in async style.  See request_async for arguments.
  # It immediately returns a HTTPClient::Connection instance as a result.
  def propfind_async(uri, extheader = PROPFIND_DEFAULT_EXTHEADER)
    request_async(:propfind, uri, nil, nil, extheader)
  end
  
  # Sends PROPPATCH request in async style.  See request_async for arguments.
  # It immediately returns a HTTPClient::Connection instance as a result.
  def proppatch_async(uri, body = nil, extheader = {})
    request_async(:proppatch, uri, nil, body, extheader)
  end
  
  # Sends TRACE request in async style.  See request_async for arguments.
  # It immediately returns a HTTPClient::Connection instance as a result.
  def trace_async(uri, query = nil, body = nil, extheader = {})
    request_async(:trace, uri, query, body, extheader)
  end

  # Sends a request in async style.  request method creates new Thread for
  # HTTP connection and returns a HTTPClient::Connection instance immediately.
  #
  # Arguments definition is the same as request.
  def request_async(method, uri, query = nil, body = nil, extheader = {})
    uri = urify(uri)
    do_request_async(method, uri, query, body, extheader)
  end

  # Resets internal session for the given URL.  Keep-alive connection for the
  # site (host-port pair) is disconnected if exists.
  def reset(uri)
    uri = urify(uri)
    @session_manager.reset(uri)
  end

  # Resets all of internal sessions.  Keep-alive connections are disconnected.
  def reset_all
    @session_manager.reset_all
  end

private

  class RetryableResponse < StandardError # :nodoc:
  end

  class KeepAliveDisconnected < StandardError # :nodoc:
  end

  def do_request(method, uri, query, body, extheader, &block)
    conn = Connection.new
    res = nil
    if HTTP::Message.file?(body)
      pos = body.pos rescue nil
    end
    retry_count = @session_manager.protocol_retry_count
    proxy = no_proxy?(uri) ? nil : @proxy
    while retry_count > 0
      body.pos = pos if pos
      req = create_request(method, uri, query, body, extheader)
      begin
        protect_keep_alive_disconnected do
          do_get_block(req, proxy, conn, &block)
        end
        res = conn.pop
        break
      rescue RetryableResponse
        res = conn.pop
        retry_count -= 1
      end
    end
    res
  end

  def do_request_async(method, uri, query, body, extheader)
    conn = Connection.new
    t = Thread.new(conn) { |tconn|
      if HTTP::Message.file?(body)
        pos = body.pos rescue nil
      end
      retry_count = @session_manager.protocol_retry_count
      proxy = no_proxy?(uri) ? nil : @proxy
      while retry_count > 0
        body.pos = pos if pos
        req = create_request(method, uri, query, body, extheader)
        begin
          protect_keep_alive_disconnected do
            do_get_stream(req, proxy, tconn)
          end
          break
        rescue RetryableResponse
          retry_count -= 1
        end
      end
    }
    conn.async_thread = t
    conn
  end

  def load_environment
    # http_proxy
    if getenv('REQUEST_METHOD')
      # HTTP_PROXY conflicts with the environment variable usage in CGI where
      # HTTP_* is used for HTTP header information.  Unlike open-uri, we
      # simply ignore http_proxy in CGI env and use cgi_http_proxy instead.
      self.proxy = getenv('cgi_http_proxy')
    else
      self.proxy = getenv('http_proxy')
    end
    # no_proxy
    self.no_proxy = getenv('no_proxy')
  end

  def getenv(name)
    ENV[name.downcase] || ENV[name.upcase]
  end

  def follow_redirect(method, uri, query, body, extheader, &block)
    uri = urify(uri)
    if block
      filtered_block = proc { |r, str|
        block.call(str) if HTTP::Status.successful?(r.status)
      }
    end
    if HTTP::Message.file?(body)
      pos = body.pos rescue nil
    end
    retry_number = 0
    while retry_number < @follow_redirect_count
      body.pos = pos if pos
      res = do_request(method, uri, query, body, extheader, &filtered_block)
      if HTTP::Status.successful?(res.status)
        return res
      elsif HTTP::Status.redirect?(res.status)
        uri = urify(@redirect_uri_callback.call(uri, res))
        retry_number += 1
      else
        raise BadResponseError.new("unexpected response: #{res.header.inspect}", res)
      end
    end
    raise BadResponseError.new("retry count exceeded", res)
  end

  def protect_keep_alive_disconnected
    begin
      yield
    rescue KeepAliveDisconnected
      yield
    end
  end

  def create_request(method, uri, query, body, extheader)
    method = method.to_s.upcase
    if extheader.is_a?(Hash)
      extheader = extheader.to_a
    else
      extheader = extheader.dup
    end
    boundary = nil
    if body
      dummy, content_type = extheader.find { |key, value|
        key.downcase == 'content-type'
      }
      if content_type
        if /\Amultipart/ =~ content_type
          if content_type =~ /boundary=(.+)\z/
            boundary = $1
          else
            boundary = create_boundary
            content_type = "#{content_type}; boundary=#{boundary}"
            extheader = override_header(extheader, 'Content-Type', content_type)
          end
        end
      elsif method == 'POST'
        if file_in_form_data?(body)
          boundary = create_boundary
          content_type = "multipart/form-data; boundary=#{boundary}"
        else
          content_type = 'application/x-www-form-urlencoded'
        end
        extheader << ['Content-Type', content_type]
      end
    end
    req = HTTP::Message.new_request(method, uri, query, body, boundary)
    extheader.each do |key, value|
      req.header.add(key, value)
    end
    if @cookie_manager && cookie = @cookie_manager.find(uri)
      req.header.add('Cookie', cookie)
    end
    req
  end

  def create_boundary
    Digest::SHA1.hexdigest(Time.now.to_s)
  end

  def file_in_form_data?(body)
    HTTP::Message.multiparam_query?(body) &&
      body.any? { |k, v| HTTP::Message.file?(v) }
  end

  def override_header(extheader, key, value)
    result = []
    extheader.each do |k, v|
      if k.downcase == key.downcase
        result << [key, value]
      else
        result << [k, v]
      end
    end
    result
  end

  NO_PROXY_HOSTS = ['localhost']

  def no_proxy?(uri)
    if !@proxy or NO_PROXY_HOSTS.include?(uri.host)
      return true
    end
    unless @no_proxy
      return false
    end
    @no_proxy.scan(/([^:,]+)(?::(\d+))?/) do |host, port|
      if /(\A|\.)#{Regexp.quote(host)}\z/i =~ uri.host &&
          (!port || uri.port == port.to_i)
        return true
      end
    end
    false
  end

  def https?(uri)
    uri.scheme.downcase == 'https'
  end

  # !! CAUTION !!
  #   Method 'do_get*' runs under MT conditon. Be careful to change.
  def do_get_block(req, proxy, conn, &block)
    @request_filter.each do |filter|
      filter.filter_request(req)
    end
    if str = @test_loopback_response.shift
      dump_dummy_request_response(req.body.dump, str) if @debug_dev
      conn.push(HTTP::Message.new_response(str))
      return
    end
    content = block ? nil : ''
    res = HTTP::Message.new_response(content)
    @debug_dev << "= Request\n\n" if @debug_dev
    sess = @session_manager.query(req, proxy)
    res.peer_cert = sess.ssl_peer_cert
    @debug_dev << "\n\n= Response\n\n" if @debug_dev
    do_get_header(req, res, sess)
    conn.push(res)
    sess.get_body do |part|
      if block
        block.call(res, part)
      else
        content << part
      end
    end
    @session_manager.keep(sess) unless sess.closed?
    commands = @request_filter.collect { |filter|
      filter.filter_response(req, res)
    }
    if commands.find { |command| command == :retry }
      raise RetryableResponse.new
    end
  end

  def do_get_stream(req, proxy, conn)
    @request_filter.each do |filter|
      filter.filter_request(req)
    end
    if str = @test_loopback_response.shift
      dump_dummy_request_response(req.body.dump, str) if @debug_dev
      conn.push(HTTP::Message.new_response(StringIO.new(str)))
      return
    end
    piper, pipew = IO.pipe
    res = HTTP::Message.new_response(piper)
    @debug_dev << "= Request\n\n" if @debug_dev
    sess = @session_manager.query(req, proxy)
    res.peer_cert = sess.ssl_peer_cert
    @debug_dev << "\n\n= Response\n\n" if @debug_dev
    do_get_header(req, res, sess)
    conn.push(res)
    sess.get_body do |part|
      pipew.syswrite(part)
    end
    pipew.close
    @session_manager.keep(sess) unless sess.closed?
    commands = @request_filter.collect { |filter|
      filter.filter_response(req, res)
    }
    # ignore commands (not retryable in async mode)
  end

  def do_get_header(req, res, sess)
    res.version, res.status, res.reason, headers = sess.get_header
    headers.each do |key, value|
      res.header.add(key, value)
    end
    if @cookie_manager
      res.header['set-cookie'].each do |cookie|
        @cookie_manager.parse(cookie, req.header.request_uri)
      end
    end
  end

  def dump_dummy_request_response(req, res)
    @debug_dev << "= Dummy Request\n\n"
    @debug_dev << req
    @debug_dev << "\n\n= Dummy Response\n\n"
    @debug_dev << res
  end
end
