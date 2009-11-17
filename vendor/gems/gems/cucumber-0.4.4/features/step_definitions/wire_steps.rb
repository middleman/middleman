Given /^there is a wire server running on port (\d+) which understands the following protocol:$/ do |port, table|
  protocol = table.hashes
  in_current_dir do
    @wire_pid = fork do
      @server = FakeWireServer.new(port.to_i, protocol)
      @server.run
    end
  end
end

After('@wire') do
  Process.kill('KILL', @wire_pid)
  Process.wait
end