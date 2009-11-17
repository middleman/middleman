require 'rubygems/local_remote_options'

class Gem::AbstractCommand < Gem::Command
  include Gem::LocalRemoteOptions

  URL = "http://gemcutter.org"

  def api_key
    Gem.configuration[:gemcutter_key]
  end

  def gemcutter_url
    ENV['GEMCUTTER_URL'] || 'https://gemcutter.org'
  end

  def setup
    use_proxy! if http_proxy
    sign_in unless api_key
  end

  def sign_in
    say "Enter your Gemcutter credentials. Don't have an account yet? Create one at #{URL}/sign_up"

    email = ask("Email: ")
    password = ask_for_password("Password: ")

    response = make_request(:get, "api_key") do |request|
      request.basic_auth email, password
    end

    case response
    when Net::HTTPSuccess
      Gem.configuration[:gemcutter_key] = response.body
      Gem.configuration.write
      say "Signed in. Your api key has been stored in ~/.gemrc"
    else
      say response.body
      terminate_interaction
    end
  end

  def make_request(method, path)
    require 'net/http'
    require 'net/https'

    url = URI.parse("#{gemcutter_url}/#{path}")

    http = proxy_class.new(url.host, url.port)

    if url.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
    end

    request_method =
      case method
      when :get
        proxy_class::Get
      when :post
        proxy_class::Post
      when :put
        proxy_class::Put
      when :delete
        proxy_class::Delete
      else
        raise ArgumentError
      end

    request = request_method.new(url.path)
    yield request if block_given?
    http.request(request)
  end

  def use_proxy!
    proxy_uri = http_proxy
    @proxy_class = Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
  end

  def proxy_class
    @proxy_class || Net::HTTP
  end

  # @return [URI, nil] the HTTP-proxy as a URI if set; +nil+ otherwise
  def http_proxy
    proxy = Gem.configuration[:http_proxy] || ENV['http_proxy'] || ENV['HTTP_PROXY']
    return nil if proxy.nil? || proxy == :no_proxy
    URI.parse(proxy)
  end

  def ask_for_password(message)
    system "stty -echo"
    password = ask(message)
    system "stty echo"
    ui.say("\n")
    password
  end
end
