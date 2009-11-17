require 'socket'
require 'json'

class FakeWireServer
  def initialize(port, protocol_table)
    @port, @protocol_table = port, protocol_table
  end

  def run
    @server = TCPServer.open(@port)
    loop { handle_connections }
  end

  private

  def handle_connections
    Thread.start(@server.accept) { |socket| open_session_on socket }
  end

  def open_session_on(socket)
    begin
      SocketSession.new(socket, @protocol_table).start
    rescue Exception => e
      raise e
    ensure
      socket.close
    end
  end
  
  class SocketSession
    def initialize(socket, protocol)
      @socket = socket
      @protocol = protocol
    end

    def start
      while message = @socket.gets
        handle(message)
      end
    end

    private
    
    def handle(data)
      if protocol_entry = response_to(data.strip)
        send_response(protocol_entry['response'])
      else
        serialized_exception = { :message => "Not understood: #{data}", :backtrace => [] }
        send_response(['fail', serialized_exception ].to_json)
      end
    end

    def response_to(data)
      @protocol.detect do |entry| 
        JSON.parse(entry['request']) == JSON.parse(data)
      end
    end

    def send_response(response)
      @socket.puts response + "\n"
    end
  end
end