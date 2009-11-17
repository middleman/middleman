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


# Boring stuff with strings.
module MaRuKu; module Strings
	
	def add_tabs(s,n=1,char="\t")
		s.split("\n").map{|x| char*n+x }.join("\n")
	end
	
	TabSize = 4;
	
	def split_lines(s)
		s.gsub("\r","").split("\n")
	end
	
	# This parses email headers. Returns an hash. 
	#
	# +hash['data']+ is the message.
	#
	# Keys are downcased, space becomes underscore, converted to symbols.
	#
	#     My key: true
	#
	# becomes:
	#
	#     {:my_key => true}
	#
	def parse_email_headers(s)
		keys={}
		match = (s =~ /\A((\w[\w\s\_\-]+: .*\n)+)\s*\n/)
		if match != 0
			keys[:data] = s
		else
			keys[:data] = $'
			headers = $1
			headers.split("\n").each do |l| 
# Fails if there are other ':' characters.
#				k, v = l.split(':')
				k, v = l.split(':', 2)
				k, v = normalize_key_and_value(k, v)
				k = k.to_sym
#				puts "K = #{k}, V=#{v}"
				keys[k] = v
			end
		end
		keys
	end

	# Keys are downcased, space becomes underscore, converted to symbols.
	def normalize_key_and_value(k,v)
		v = v ? v.strip : true # no value defaults to true
		k = k.strip
		
		# check synonyms
		v = true if ['yes','true'].include?(v.to_s.downcase)
		v = false if ['no','false'].include?(v.to_s.downcase)
	
		k = k.downcase.gsub(' ','_')
		return k, v
	end
	
	# Returns the number of leading spaces, considering that
	# a tab counts as `TabSize` spaces.
	def number_of_leading_spaces(s)
		n=0; i=0;
		while i < s.size 
			c = s[i,1]
			if c == ' '
				i+=1; n+=1;
			elsif c == "\t"
				i+=1; n+=TabSize;
			else
				break
			end
		end
		n
	end

	# This returns the position of the first real char in a list item
	#
	# For example: 
	#     '*Hello' # => 1
	#     '* Hello' # => 2
	#     ' * Hello' # => 3
	#     ' *   Hello' # => 5
	#     '1.Hello' # => 2
	#     ' 1.  Hello' # => 5
	
	def spaces_before_first_char(s)
		case s.md_type
		when :ulist
			i=0;
			# skip whitespace if present
			while s[i,1] =~ /\s/; i+=1 end
			# skip indicator (+, -, *)
			i+=1
			# skip optional whitespace
			while s[i,1] =~ /\s/; i+=1 end
			return i
		when :olist
			i=0;
			# skip whitespace
			while s[i,1] =~ /\s/; i+=1 end
			# skip digits
			while s[i,1] =~ /\d/; i+=1 end
			# skip dot
			i+=1
			# skip whitespace
			while s[i,1] =~ /\s/; i+=1 end
			return i
		else
			tell_user "BUG (my bad): '#{s}' is not a list"
			0
		end
	end

	# Counts the number of leading '#' in the string
	def num_leading_hashes(s)
		i=0;
		while i<(s.size-1) && (s[i,1]=='#'); i+=1 end
		i	
	end
	
	# Strips initial and final hashes
	def strip_hashes(s)
		s = s[num_leading_hashes(s), s.size]
		i = s.size-1
		while i > 0 && (s[i,1] =~ /(#|\s)/); i-=1; end
		s[0, i+1].strip
	end
	
	# change space to "_" and remove any non-word character
	def sanitize_ref_id(x)
		x.strip.downcase.gsub(' ','_').gsub(/[^\w]/,'')
	end


	# removes initial quote
	def unquote(s)
		s.gsub(/^>\s?/,'')
	end

	# toglie al massimo n caratteri
	def strip_indent(s, n) 
		i = 0
		while i < s.size && n>0
			c = s[i,1]
			if c == ' '
				n-=1;
			elsif c == "\t"
				n-=TabSize;
			else
				break
			end
			i+=1
		end
		s[i, s.size]
	end

	def dbg_describe_ary(a, prefix='')
		i = 0 
		a.each do |l|
			puts "#{prefix} (#{i+=1})# #{l.inspect}"
		end
	end

	def force_linebreak?(l)
		l =~ /  $/
	end

end
end
