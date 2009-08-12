require "forwardable"

module Rack
  module Test
    module Methods
      extend Forwardable

      def rack_mock_session(name = :default)
        return build_rack_mock_session unless name

        @_rack_mock_sessions ||= {}
        @_rack_mock_sessions[name] ||= build_rack_mock_session
      end

      def build_rack_mock_session
        Rack::MockSession.new(app)
      end

      def rack_test_session(name = :default)
        return build_rack_test_session(name) unless name

        @_rack_test_sessions ||= {}
        @_rack_test_sessions[name] ||= build_rack_test_session(name)
      end

      def build_rack_test_session(name)
        Rack::Test::Session.new(rack_mock_session(name))
      end

      def current_session
        rack_test_session(_current_session_names.last)
      end

      def with_session(name)
        _current_session_names.push(name)
        yield rack_test_session(name)
        _current_session_names.pop
      end

      def _current_session_names
        @_current_session_names ||= [:default]
      end

      METHODS = [
        :request,

        # HTTP verbs
        :get,
        :post,
        :put,
        :delete,
        :head,

        # Redirects
        :follow_redirect!,

        # Header-related features
        :header,
        :set_cookie,
        :clear_cookies,
        :authorize,
        :basic_authorize,
        :digest_authorize,

        # Expose the last request and response
        :last_response,
        :last_request
      ]

      def_delegators :current_session, *METHODS
    end
  end
end
