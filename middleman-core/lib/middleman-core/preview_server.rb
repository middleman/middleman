# frozen_string_literal: true

require 'webrick'
require 'webrick/https'
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

      attr_reader :app, :ssl_certificate, :ssl_private_key, :environment, :server_information

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

        mount_instance(the_app)

        app.logger.debug %(== Server information is provided by #{server_information.handler})
        app.logger.debug %(== The Middleman is running in "#{environment}" environment)
        app.logger.debug format('== The Middleman preview server is bound to %<url>s', url: ServerUrl.new(hosts: server_information.listeners, port: server_information.port, https: server_information.https?).to_bind_addresses.join(', '))
        app.logger.info format('== View your site at %<url>s', url: ServerUrl.new(hosts: server_information.site_addresses, port: server_information.port, https: server_information.https?).to_urls.join(', '))
        app.logger.info format('== Inspect your site configuration at %<url>s', url: ServerUrl.new(hosts: server_information.site_addresses, port: server_information.port, https: server_information.https?).to_config_urls.join(', '))

        @initialized ||= false
        return if @initialized

        @initialized = true

        register_signal_handlers

        # Save the last-used @options so it may be re-used when
        # reloading later on.
        ::Middleman::Profiling.report('server_start')

        app.execute_callbacks(:before_server, [ServerInformationCallbackProxy.new(server_information)])

        if @options[:daemon]
          # To output the child PID, let's make preview server a daemon by hand
          child_pid = fork

          if child_pid
            app.logger.info "== Middleman preview server is running in background with PID #{child_pid}"
            Process.detach child_pid
            exit 0
          else
            $stdout.reopen('/dev/null', 'w')
            $stderr.reopen('/dev/null', 'w')
            $stdin.reopen('/dev/null', 'r')
          end
        end

        loop do
          @webrick.start

          # $mm_shutdown is set by the signal handler
          if $mm_shutdown
            shutdown
            exit
          elsif $mm_reload
            $mm_reload = false
            reload
          end
        end
      end

      # Detach the current Middleman::Application instance
      # @return [void]
      def stop
        begin
          app.logger.info '== The Middleman is shutting down'
        rescue StandardError
          # if the user closed their terminal STDOUT/STDERR won't exist
        end

        unmount_instance
      end

      # Simply stop, then start the server
      # @return [void]
      def reload
        app.logger.info '== The Middleman is reloading'

        app.execute_callbacks(:reload)

        begin
          app = initialize_new_app
        rescue StandardError => e
          warn "Error reloading Middleman: #{e}\n#{e.backtrace.join("\n")}"
          app.logger.info '== The Middleman is still running the application from before the error'
          return
        end

        unmount_instance

        @webrick.shutdown
        @webrick = nil

        mount_instance(app)

        app.logger.info '== The Middleman has reloaded'
      end

      # Stop the current instance, exit Webrick
      # @return [void]
      def shutdown
        stop
        @webrick.shutdown
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
          app.logger.warn format(
            '== The Middleman uses a different port "%<new_port>s" then the configured one "%<old_port>s" because some other server is listening on that port.',
            new_port: server_information.port,
            old_port: configured_port
          )
        end

        @environment = possible_from_cli(:environment, app.config)

        @ssl_certificate = possible_from_cli(:ssl_certificate, app.config)
        @ssl_private_key = possible_from_cli(:ssl_private_key, app.config)

        app.files.on_change :reload do
          $mm_reload = true
          @webrick.stop
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

      # Trap some interrupt signals and shut down smoothly
      # @return [void]
      def register_signal_handlers
        %w[INT HUP TERM QUIT].each do |sig|
          next unless Signal.list[sig]

          Signal.trap(sig) do
            # Do as little work as possible in the signal context
            $mm_shutdown = true

            @webrick.stop
          end
        end
      end

      # Initialize webrick
      # @return [void]
      def setup_webrick(is_logging)
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

        http_opts[:Logger] = if is_logging
                               FilteredWebrickLog.new
                             else
                               ::WEBrick::Log.new(nil, 0)
                             end

        begin
          ::WEBrick::HTTPServer.new(http_opts)
        rescue Errno::EADDRINUSE
          port = http_opts[:Port]
          warn %(== Port #{port} is already in use. This could mean another instance of middleman is already running. Please make sure port #{port} is free and start `middleman server` again, or choose another port by running `middleman server —-port=#{port + 1}` instead.)
        end
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

        cert.sign(rsa, OpenSSL::Digest.new('SHA256'))

        [cert, rsa]
      end

      # Attach a new Middleman::Application instance
      # @param [Middleman::Application] app
      # @return [void]
      def mount_instance(app)
        @app = app

        @webrick ||= setup_webrick(@options[:debug] || false)

        rack_app = ::Middleman::Rack.new(@app).to_app
        @webrick.mount '/', ::Rack::Handler::WEBrick, rack_app
      end

      # Detach the current Middleman::Application instance
      # @return [void]
      def unmount_instance
        @webrick.unmount '/'

        @app.shutdown!

        @app = nil
      end
    end

    class FilteredWebrickLog < ::WEBrick::Log
      def log(level, data)
        super(level, data) unless /Could not determine content-length of response body./.match?(data)
      end
    end
  end
end
