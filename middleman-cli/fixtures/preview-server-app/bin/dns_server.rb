#!/usr/bin/env ruby

require 'rubydns'
require 'psych'

db_file = ARGV[0]
port = ARGV[1] || 5300

db =  if File.file? db_file
        $stderr.puts 'Found dns db'
        Psych.load_file(db_file)
      else
        $stderr.puts 'Found no dns db. Use default db.'

        {
          /www\.example\.org/ => '1.1.1.1'
        }
      end

interfaces = [
    [:udp, "127.0.0.1", port],
    [:tcp, "127.0.0.1", port]
]


# Start the RubyDNS server
RubyDNS::run_server(listen: interfaces) do
  db.each do |matcher, result|
    match(matcher, Resolv::DNS::Resource::IN::A) do |transaction|
      transaction.respond!(result)
    end
  end
end
