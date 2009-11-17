$LOAD_PATH.unshift "../net-ssh/lib"
require './lib/net/scp/version'

begin
  require 'echoe'
rescue LoadError
  abort "You'll need to have `echoe' installed to use Net::SCP's Rakefile"
end

version = Net::SCP::Version::STRING.dup
if ENV['SNAPSHOT'].to_i == 1
  version << "." << Time.now.utc.strftime("%Y%m%d%H%M%S")
end

Echoe.new('net-scp', version) do |p|
  p.project          = "net-ssh"
  p.changelog        = "CHANGELOG.rdoc"

  p.author           = "Jamis Buck"
  p.email            = "jamis@jamisbuck.org"
  p.summary          = "A pure Ruby implementation of the SCP client protocol"
  p.url              = "http://net-ssh.rubyforge.org/scp"

  p.dependencies     = ["net-ssh >=1.99.1"]

  p.need_zip         = true
  p.include_rakefile = true

  p.rdoc_pattern     = /^(lib|README.rdoc|CHANGELOG.rdoc)/
end