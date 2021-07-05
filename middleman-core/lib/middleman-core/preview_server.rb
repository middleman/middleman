# frozen_string_literal: true

require 'openssl'
require 'middleman-core/meta_pages'
require 'middleman-core/logger'
require 'middleman-core/rack'
require 'middleman-core/preview_server/server_information'
require 'middleman-core/preview_server/server_url'
require 'middleman-core/preview_server/server_information_callback_proxy'

module Middleman
  class PreviewServer
    class << self
      extend Forwardable

      attr_reader :app, :server_pid, :ssl_certificate, :ssl_private_key, :environment, :server_information

      # Start an instance of Middleman::Application
      # @return [void]
      def start(options_hash = ::Middleman::EMPTY_HASH, cli_options_hash = ::Middleman::EMPTY_HASH)
        # Do not buffer output, otherwise testing of output does not work
        $stdout.sync = true
        $stderr.sync = true

        @options = options_hash
        @cli_options = cli_options_hash
        @server_information = ServerInformation.new
        @server_information.https = (@options[:https] == true)

        # New app evaluates the middleman configuration. Since this can be
        # invalid as well, we need to evaluate the configuration BEFORE
        # checking for validity
        the_app = initialize_new_app

        # And now comes the check
        unless server_information.valid?
          warn %(== Running Middleman failed: #{server_information.reason}. Please fix that and try again.)
          exit 1
        end

        logger.debug %(== Server information is provided by #{server_information.handler})
        logger.debug %(== The Middleman is running in "#{environment}" environment)
        logger.debug format('== The Middleman preview server is bound to %<url>s', url: ServerUrl.new(hosts: server_information.listeners, port: server_information.port, https: server_information.https?).to_bind_addresses.join(', '))
        logger.info format('== View your site at %<url>s', url: ServerUrl.new(hosts: server_information.site_addresses, port: server_information.port, https: server_information.https?).to_urls.join(', '))
        logger.info format('== Inspect your site configuration at %<url>s', url: ServerUrl.new(hosts: server_information.site_addresses, port: server_information.port, https: server_information.https?).to_config_urls.join(', '))

        @initialized ||= false
        return if @initialized

        @initialized = true

        # Transform the current process into a daemon
        if @options[:daemon]
          # To output the child PID, let's make preview server a daemon by hand
          Process.daemon(true)
          logger.info "== Middleman preview server is running in background with PID #{Process.pid}"
        end

        signals_queue = Queue.new

        %w[INT HUP TERM QUIT].each do |sig|
          next unless Signal.list[sig]

          Signal.trap(sig) do
            signals_queue << sig
          end
        end

        start_webserver(the_app)

        signals_queue.pop # waiting for quit signals

        stop
      end

      def start_webserver(app)
        @app = app
        @app.execute_callbacks(:before_server, [ServerInformationCallbackProxy.new(server_information)])

        ::Middleman::Profiling.report('server_start')

        @server_pid = fork do
          server = ::Rack::Handler.get(server_information.server) || ::Rack::Handler.default

          logger.info %(== The Middleman selected #{server} rack handler)

          %w[INT HUP TERM QUIT].each do |sig|
            next unless Signal.list[sig]

            Signal.trap(sig) do
              if server.respond_to?(:shutdown)
                server.shutdown
              else
                exit
              end
            end
          end

          server_options = basic_server_options

          if server.to_s == 'Rack::Handler::WEBrick'
            server_options[:Logger] = (@options[:debug] ? logger : ::WEBrick::Log.new(nil, 0))
          elsif server.to_s == 'Rack::Handler::Puma'
            server_options[:Silent] = !@options[:debug]
            server_options[:Verbose] = @options[:debug]
          end

          server.run(::Middleman::Rack.new(app).to_app, **server_options)
        end
      end

      # Detach the current Middleman::Application instance
      # @return [void]
      def stop
        begin
          logger.info '== The Middleman is shutting down'
        rescue StandardError
          # if the user closed their terminal STDOUT/STDERR won't exist
        end

        stop_server_and_app
      end

      def logger
        @logger ||= Logger.new(@options[:debug] ? :debug : :info)
      end

      # Simply stop, then start the server
      # @return [void]
      def reload
        logger.info '== The Middleman is reloading'

        app.execute_callbacks(:reload)

        begin
          the_app = initialize_new_app
        rescue StandardError => e
          warn "Error reloading Middleman: #{e}\n#{e.backtrace.join("\n")}"
          logger.info '== The Middleman is still running the application from before the error'
          return
        end

        stop_server_and_app

        start_webserver(the_app)

        logger.info '== The Middleman has reloaded'
      end

      # Stop the current instance, exit server
      # @return [void]
      def shutdown
        stop
      end

      private

      def initialize_new_app
        opts = @options.dup
        cli_options = @cli_options.dup

        ::Middleman::Logger.singleton(
          opts[:debug] ? 0 : 1,
          opts[:instrumenting] || false
        )

        app = ::Middleman::Application.new do
          config[:cli_options] = cli_options.each_with_object({}) do |(k, v), sum|
            sum[k] = v
          end

          ready do
            unless config[:watcher_disable]
              match_against = [
                /^config\.rb$/,
                %r{^environments/[^\.](.*)\.rb$},
                %r{^lib/[^\.](.*)\.rb$},
                %r{^#{config[:helpers_dir]}/[^\.](.*)\.rb$}
              ]

              # config.rb
              watcher = files.watch :reload,
                                    path: root,
                                    only: match_against

              # Hack around bower_components in root.
              watcher.listener.ignore(/^bower_components/)

              # Hack around node_modules in root.
              watcher.listener.ignore(/^node_modules/)

              # Hack around sass cache in root.
              watcher.listener.ignore(/^\.sass-cache/)

              # Hack around bundler cache in root.
              watcher.listener.ignore(%r{^vendor/bundle})
            end
          end
        end

        # store configured port to make a check later on possible
        configured_port = possible_from_cli(:port, app.config)

        # Use configuration values to set `bind_address` etc. in
        # `server_information`
        server_information.use(bind_address: possible_from_cli(:bind_address, app.config),
                               port: possible_from_cli(:port, app.config),
                               server_name: possible_from_cli(:server_name, app.config),
                               https: possible_from_cli(:https, app.config))

        unless server_information.port == configured_port
          logger.warn format(
            '== The Middleman uses a different port "%<new_port>s" then the configured one "%<old_port>s" because some other server is listening on that port.',
            new_port: server_information.port,
            old_port: configured_port
          )
        end

        @environment = possible_from_cli(:environment, app.config)

        @ssl_certificate = possible_from_cli(:ssl_certificate, app.config)
        @ssl_private_key = possible_from_cli(:ssl_private_key, app.config)

        app.files.on_change :reload do
          reload
        end

        # Add in the meta pages application
        meta_app = Middleman::MetaPages::Application.new(app)
        app.map '/__middleman' do |rack|
          rack.run meta_app
        end

        app
      end

      def possible_from_cli(key, config)
        @cli_options[key] || config[key]
      end

      # Get server options
      # @return [void]
      def basic_server_options
        http_opts = {
          Port: server_information.port,
          AccessLog: [],
          ServerName: server_information.server_name,
          BindAddress: server_information.bind_address.to_s,
          DoNotReverseLookup: true
        }

        if server_information.https?
          http_opts[:SSLEnable] = true

          if ssl_certificate || ssl_private_key
            raise 'You must provide both :ssl_certificate and :ssl_private_key' unless ssl_private_key && ssl_certificate

            http_opts[:SSLCertificate] = OpenSSL::X509::Certificate.new ::File.read ssl_certificate
            http_opts[:SSLPrivateKey] = OpenSSL::PKey::RSA.new ::File.read ssl_private_key
          else
            # use a generated self-signed cert
            http_opts[:SSLCertName] = [
              %w[CN localhost],
              ['CN', server_information.server_name]
            ].uniq
            cert, key = create_self_signed_cert(4096, [['CN', server_information.server_name]], server_information.site_addresses, 'Middleman Preview Server')
            http_opts[:SSLCertificate] = cert
            http_opts[:SSLPrivateKey] = key
          end
        end

        http_opts
      end

      # Copy of https://github.com/nahi/ruby/blob/webrick_trunk/lib/webrick/ssl.rb#L39
      # that uses a different serial number each time the cert is generated in order to
      # avoid errors in Firefox. Also doesn't print out stuff to $stderr unnecessarily.
      def create_self_signed_cert(bits, cn, aliases, comment)
        rsa = OpenSSL::PKey::RSA.new(bits)
        cert = OpenSSL::X509::Certificate.new
        cert.version = 2
        cert.serial = Time.now.to_i % (1 << 20)
        name = OpenSSL::X509::Name.new(cn)
        cert.subject = name
        cert.issuer = name
        cert.not_before = Time.now
        cert.not_after = Time.now + (365 * 24 * 60 * 60)
        cert.public_key = rsa.public_key

        ef = OpenSSL::X509::ExtensionFactory.new(nil, cert)
        ef.issuer_certificate = cert
        cert.extensions = [
          ef.create_extension('basicConstraints', 'CA:FALSE'),
          ef.create_extension('keyUsage', 'keyEncipherment'),
          ef.create_extension('subjectKeyIdentifier', 'hash'),
          ef.create_extension('extendedKeyUsage', 'serverAuth'),
          ef.create_extension('nsComment', comment)
        ]
        aki = ef.create_extension('authorityKeyIdentifier',
                                  'keyid:always,issuer:always')
        cert.add_extension(aki)
        cert.add_extension ef.create_extension('subjectAltName', aliases.map { |d| "DNS: #{d}" }.join(','))

        cert.sign(rsa, OpenSSL::Digest::SHA1.new)

        [cert, rsa]
      end

      # Stop Middleman::Application instance and web server
      # @return [void]
      def stop_server_and_app
        app.shutdown!

        Process.kill('QUIT', server_pid)
        Process.wait(server_pid)

        @server_pid = nil
        @app = nil
      end
    end
  end
end
