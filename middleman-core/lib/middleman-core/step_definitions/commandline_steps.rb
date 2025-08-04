When /^I stop (?:middleman|all commands) if the output( of the last command)? contains:$/ do |last_command, expected|
  begin
    Timeout.timeout(aruba.config.exit_timeout) do
      loop do
        fail "You need to start middleman interactively first." unless last_command_started

        if unescape_text(last_command_started.output) =~ Regexp.new(unescape_text(expected))
          all_commands.each { |p| p.terminate }
          break
        end

        sleep 0.1
      end
    end
  rescue ::ChildProcess::TimeoutError, Timeout::Error
    last_command_started.terminate
  ensure
    aruba.announcer.announce :stdout, last_command_started.stdout
    aruba.announcer.announce :stderr, last_command_started.stderr
  end
end

# Make it just a long running process
Given /`(.*?)` is running in background/ do |cmd|
  run_command(cmd, exit_timeout: 120)
end

Given /I have a local hosts file with:/ do |string|
  step 'I set the environment variables to:', table(
    %(
      | variable | value  |
      | MM_HOSTSRC  | .hosts |
    )
  )

  step 'a file named ".hosts" with:', string
end

Given /I start a dns server with:/ do |string|
  @dns_server.terminate if defined? @dns_server

  port = 5300
  db_file = 'dns.db'

  step 'I set the environment variables to:', table(
    %(
       | variable  | value            |
       | MM_DNSRC  | 127.0.0.1:#{port}|
    )
  )

  set_environment_variable 'PATH', File.expand_path(File.join(aruba.current_directory, 'bin')) + ':' + ENV['PATH']
  write_file db_file, string

  @dns_server = run_command("dns_server.rb #{db_file} #{port}", exit_timeout: 120)
end

Given /I start a mdns server with:/ do |string|
  @mdns_server.terminate if defined? @mdns_server

  port = 5301
  db_file = 'mdns.db'

  step 'I set the environment variables to:', table(
    %(
       | variable  | value             |
       | MM_MDNSRC  | 127.0.0.1:#{port}|
    )
  )

  set_environment_variable 'PATH', File.expand_path(File.join(aruba.current_directory, 'bin')) + ':' + ENV['PATH']
  write_file db_file, string

  @mdns_server = run_command("dns_server.rb #{db_file} #{port}", exit_timeout: 120)
end

Given /I start a mdns server for the local hostname/ do
  step %(I start a mdns server with:), "#{Socket.gethostname}: 127.0.0.1"
end

# Make sure each and every process is really dead
After do
  all_commands.each { |p| p.terminate }
end
