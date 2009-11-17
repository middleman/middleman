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



#m  Any method that detects formatting error calls the
#m  maruku_error() method. 
#m  if @meta[:on_error] == 
#m
#m  - :warning   write on the standard err (or @error_stream if defined), 
#m              then do your best.
#m  - :ignore    be shy and try to continue
#m  - :raise     raises a MarukuException
#m
#m  default is :raise

module MaRuKu
	
	class Exception < RuntimeError
	end
	
module Errors
	
	def maruku_error(s,src=nil,con=nil)
		policy = get_setting(:on_error)
		
		case policy
		when :ignore 
		when :raise
			raise_error create_frame(describe_error(s,src,con))
		when :warning
			tell_user create_frame(describe_error(s,src,con))
		else
			raise "BugBug: policy = #{policy.inspect}"
		end
	end
	
	def maruku_recover(s,src=nil,con=nil)
		tell_user create_frame(describe_error(s,src,con))
	end
	
	alias error maruku_error

	def raise_error(s)
		raise MaRuKu::Exception, s, caller
	end

	def tell_user(s)
		error_stream = self.attributes[:error_stream] || $stderr
		error_stream << s 
	end
	
	def create_frame(s)
		n = 75
		"\n" +
		" "+"_"*n + "\n"+
		"| Maruku tells you:\n" +
		"+" + ("-"*n) +"\n"+
		add_tabs(s,1,'| ') + "\n" +
		"+" + ("-"*n) + "\n" +
		add_tabs(caller[0, 5].join("\n"),1,'!') + "\n" +
		"\\" + ("_"*n) + "\n"
	end

	def describe_error(s,src,con)
		t = s
		src && (t += "\n#{src.describe}\n")
		con && (t += "\n#{con.describe}\n")
		t
	end
	
end # Errors
end # MaRuKu


