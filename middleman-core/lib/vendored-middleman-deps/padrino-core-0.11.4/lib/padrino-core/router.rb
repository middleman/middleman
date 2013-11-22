module Padrino
  ##
  # This class is an extended version of Rack::URLMap.
  #
  # Padrino::Router like Rack::URLMap dispatches in such a way that the
  # longest paths are tried first, since they are most specific.
  #
  # Features:
  #
  # * Map a path to the specified App
  # * Ignore server names (this solve issues with vhost and domain aliases)
  # * Use hosts instead of server name for mappings (this help us with our vhost and domain aliases)
  #
  # @example
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
  # @api semipublic
  class Router
    def initialize(*mapping, &block)
      @mapping = []
      mapping.each { |m| map(m) }
      instance_eval(&block) if block
    end

    ##
    # Map a route path and host to a specified application.
    #
    # @param [Hash] options
    #  The options to map.
    # @option options [Sinatra::Application] :to
    #  The class of the application to mount.
    # @option options [String] :path ("/")
    #  The path to map the specified application.
    # @option options [String] :host
    #  The host to map the specified application.
    #
    # @example
    #  map(:path => "/", :to => PadrinoWeb, :host => "padrino.local")
    #
    # @return [Array] The sorted route mappings.
    # @api semipublic
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

    # The call handler setup to route a request given the mappings specified.
    def call(env)
      path_info = env["PATH_INFO"].to_s
      script_name = env['SCRIPT_NAME']
      http_host = env['HTTP_HOST']

      @mapping.each do |host, path, match, app|
        next unless host.nil? || http_host =~ host
        next unless path_info =~ match && rest = $1
        next unless rest.empty? || rest[0] == ?/

        rest = "/" if rest.empty?

        return app.call(
          env.merge(
            'SCRIPT_NAME' => (script_name + path),
            'PATH_INFO'   => rest))
      end
      [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass"}, ["Not Found: #{path_info}"]]
    end

    private

    def sort!
      @mapping = @mapping.sort_by { |h, p, m, a| -p.size }
    end
  end
end
