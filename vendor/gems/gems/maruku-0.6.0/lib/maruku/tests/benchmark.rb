#--
#   Copyright (C) 2006  Andrea Censi  <andrea (at) rubyforge.org>
#
# This file is part of Maruku.
# 
#   Maruku is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
# 
#   Maruku is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with Maruku; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#++


require 'maruku'
#require 'bluecloth'


data = $stdin.read

num = 10

if ARGV.size > 0 && ((n=ARGV[0].to_i) != 0)
	num = n
end
	
methods = 
[
	
	[Maruku,    :to_html],
#	[BlueCloth, :to_html],
	[Maruku,    :to_latex]
	
]

#methods = [[Maruku, :class]]
#num = 10

stats = 
methods .map do |c, method|
	puts "Computing for #{c}"

	start = Time.now
	doc = nil
	for i in 1..num
		$stdout.write "#{i} "; $stdout.flush
		doc = c.new(data)
	end
	stop = Time.now
	parsing = (stop-start)/num

	start = Time.now
	for i in 1..num
		$stdout.write "#{i} "; $stdout.flush
		s = doc.send method
	end
	stop = Time.now
	rendering = (stop-start)/num

	puts ("%s (%s): parsing %0.2f sec + rendering %0.2f sec "+
	"= %0.2f sec ") % [c, method, parsing,rendering,parsing+rendering]

	[c, method, parsing, rendering]
end

puts "\n\n\n"
stats.each do |x| x.push(x[2]+x[3]) end
max = stats.map{|x|x[4]}.max
stats.sort! { |x,y| x[4] <=> y[4] } . reverse!
for c, method, parsing, rendering, tot in stats
	puts ("%20s: parsing %0.2f sec + rendering %0.2f sec "+
	"= %0.2f sec   (%0.2fx)") % 
	["#{c} (#{method})", parsing,rendering,tot,max/tot]
end

