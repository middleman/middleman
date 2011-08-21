module Padrino
  ##
  # This class is an extended version of Rack::URLMap
  #
  # Padrino::Router like Rack::URLMap dispatches in such a way that the
  # longest paths are tried first, since they are most specific.
  #
  # Features:
  #
  # * Map a path to the specified App
  # * Ignore server names (this solve issues with vhost and domain aliases)
  # * Use hosts instead of server name for mappings (this help us with our vhost and doman aliases)
  #
  # ==== Options
  #
  # :to:: The class of application that you want mount
  # :path:: Map the app to the given path
  # :host:: Map the app to the given host
  #
  # ==== Examples
  #
  #   routes = Padrino::Router.new do
  #     map(:path => "/", :to => PadrinoWeb, :host => "padrino.local")
  #     map(:path => "/", :to => Admin, :host => "admin.padrino.local")
  #   end
  #   run routes
  #
  #   routes = Padrino::Router.new do
  #     map(:path => "/", :to => PadrinoWeb, :host => /*.padrino.local/)
  #   end
  #   run routes
  #
  class Router
    def initialize(*mapping, &block)
      @mapping = []
      mapping.each { |m| map(m) }
      instance_eval(&block) if block
    end

    def sort!
      @mapping = @mapping.sort_by { |h, p, m, a| -p.size }
    end

    def map(options={})
      path = options[:path] || "/"
      host = options[:host]
      app  = options[:to]

      raise ArgumentError, "paths need to start with /" if path[0] != ?/
      raise ArgumentError, "app is required" if app.nil?

      path  = path.chomp('/')
      match = Regexp.new("^#{Regexp.quote(path).gsub('/', '/+')}(.*)", nil, 'n')
      host  = Regexp.new("^#{Regexp.quote(host)}$", true, 'n') unless host.nil? || host.is_a?(Regexp)

      @mapping << [host, path, match, app]
      sort!
    end

    def call(env)
      rPath = env["PATH_INFO"].to_s
      script_name = env['SCRIPT_NAME']
      hHost, sName, sPort = env.values_at('HTTP_HOST','SERVER_NAME','SERVER_PORT')
      @mapping.each do |host, path, match, app|
        next unless host.nil? || hHost =~ host
        next unless rPath =~ match && rest = $1
        next unless rest.empty? || rest[0] == ?/

        rest = "/" if rest.empty?

        return app.call(
          env.merge(
            'SCRIPT_NAME' => (script_name + path),
            'PATH_INFO'   => rest))
      end
      [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass"}, ["Not Found: #{rPath}"]]
    end
  end # Router
end # Padrino