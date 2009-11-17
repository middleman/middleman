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


module MaRuKu; module In; module Markdown; module SpanLevelParser

# a string scanner coded by me
class CharSourceManual; end

# a wrapper around StringScanner
class CharSourceStrscan; end

# A debug scanner that checks the correctness of both
# by comparing their output
class CharSourceDebug; end

# Choose!

CharSource = CharSourceManual     # faster! 58ms vs. 65ms
#CharSource = CharSourceStrscan
#CharSource = CharSourceDebug


class CharSourceManual
	include MaRuKu::Strings
	
	def initialize(s, parent=nil)
		raise "Passed #{s.class}" if not s.kind_of? String
		@buffer = s
		@buffer_index = 0
		@parent = parent
	end
	
	# Return current char as a FixNum (or nil).
	def cur_char; @buffer[@buffer_index]   end

	# Return the next n chars as a String.
	def cur_chars(n); @buffer[@buffer_index,n]  end
	
	# Return the char after current char as a FixNum (or nil).
	def next_char; @buffer[@buffer_index+1] end
	
	def shift_char
		c = @buffer[@buffer_index]
		@buffer_index+=1
		c
	end
	
	def ignore_char
		@buffer_index+=1
		nil
	end
	
	def ignore_chars(n)
		@buffer_index+=n
		nil
	end
	
	def current_remaining_buffer
		@buffer[@buffer_index, @buffer.size-@buffer_index]
	end
	
	def cur_chars_are(string)
		# There is a bug here
		if false
			r2 = /^.{#{@buffer_index}}#{Regexp.escape string}/m
			@buffer =~ r2
		else
			cur_chars(string.size) == string
		end
	end

	def next_matches(r)
		r2 = /^.{#{@buffer_index}}#{r}/m
		md = r2.match @buffer
		return !!md
	end
	
	def read_regexp3(r)
		r2 = /^.{#{@buffer_index}}#{r}/m
		m = r2.match @buffer
		if m
			consumed = m.to_s.size - @buffer_index
#			puts "Consumed #{consumed} chars (entire is #{m.to_s.inspect})"
			ignore_chars consumed
		else
#			puts "Could not read regexp #{r2.inspect} from buffer "+
#			" index=#{@buffer_index}"
#			puts "Cur chars = #{cur_chars(20).inspect}"
#			puts "Matches? = #{cur_chars(20) =~ r}"
		end
		m
	end

		def read_regexp(r)
			r2 = /^#{r}/
			rest = current_remaining_buffer
			m = r2.match(rest)
			if m
				@buffer_index += m.to_s.size
#				puts "#{r} matched #{rest.inspect}: #{m.to_s.inspect}"
			end
			return m
		end
	
	def consume_whitespace
		while c = cur_char 
		  if (c == ?\s || c == ?\t)
#				puts "ignoring #{c}"
				ignore_char
			else
#				puts "#{c} is not ws: "<<c
				break
			end
		end
	end

	def read_text_chars(out)
		s = @buffer.size; c=nil
		while @buffer_index < s && (c=@buffer[@buffer_index]) &&
			 ((c>=?a && c<=?z) || (c>=?A && c<=?Z))
				out << c
				@buffer_index += 1
		end
	end
	
	def describe
		s = describe_pos(@buffer, @buffer_index)
		if @parent
			s += "\n\n" + @parent.describe
		end
		s
	end
	include SpanLevelParser
end

def describe_pos(buffer, buffer_index)
	len = 75
	num_before = [len/2, buffer_index].min
	num_after = [len/2, buffer.size-buffer_index].min
	num_before_max = buffer_index
	num_after_max = buffer.size-buffer_index
	
#		puts "num #{num_before} #{num_after}"
	num_before = [num_before_max, len-num_after].min
	num_after  = [num_after_max, len-num_before].min
#		puts "num #{num_before} #{num_after}"
	
	index_start = [buffer_index - num_before, 0].max
	index_end   = [buffer_index + num_after, buffer.size].min
	
	size = index_end- index_start
	
#		puts "- #{index_start} #{size}"

	str = buffer[index_start, size]
	str.gsub!("\n",'N')
	str.gsub!("\t",'T')
	
	if index_end == buffer.size 
		str += "EOF"
	end
		
	pre_s = buffer_index-index_start
	pre_s = [pre_s, 0].max
	pre_s2 = [len-pre_s,0].max
#		puts "pre_S = #{pre_s}"
	pre =" "*(pre_s) 
	
	"-"*len+"\n"+
	str + "\n" +
	"-"*pre_s + "|" + "-"*(pre_s2)+"\n"+
#		pre + "|\n"+
	pre + "+--- Byte #{buffer_index}\n"+
	
	"Shown bytes [#{index_start} to #{size}] of #{buffer.size}:\n"+
	add_tabs(buffer,1,">")
	
#		"CharSource: At character #{@buffer_index} of block "+
#		" beginning with:\n    #{@buffer[0,50].inspect} ...\n"+
#		" before: \n     ... #{cur_chars(50).inspect} ... "
end


require 'strscan'

class CharSourceStrscan
	include SpanLevelParser
	include MaRuKu::Strings
	
	def initialize(s, parent=nil)
		@s = StringScanner.new(s)
		@parent = parent
	end
	
	# Return current char as a FixNum (or nil).
	def cur_char
		 @s.peek(1)[0]
	end

	# Return the next n chars as a String.
	def cur_chars(n); 
		@s.peek(n)
	end
	
	# Return the char after current char as a FixNum (or nil).
	def next_char; 
		@s.peek(2)[1]
	end
	
	def shift_char
		(@s.get_byte)[0]
	end
	
	def ignore_char
		@s.get_byte
		nil
	end
	
	def ignore_chars(n)
		n.times do @s.get_byte end
		nil
	end
	
	def current_remaining_buffer
		@s.rest #nil #@buffer[@buffer_index, @buffer.size-@buffer_index]
	end
	
	def cur_chars_are(string)
		cur_chars(string.size) == string
	end

	def next_matches(r)
		len = @s.match?(r)
		return !!len
	end
	
	def read_regexp(r)
		string = @s.scan(r)
		if string
			return r.match(string)
		else
			return nil
		end
	end
	
	def consume_whitespace
		@s.scan(/\s+/)
		nil
	end
	
	def describe
		describe_pos(@s.string, @s.pos)
	end
	
end


class CharSourceDebug
	def initialize(s, parent)
		@a = CharSourceManual.new(s, parent)
		@b = CharSourceStrscan.new(s, parent)
	end
	
	def method_missing(methodname, *args)
		a_bef = @a.describe
		b_bef = @b.describe
		
		a = @a.send(methodname, *args)
		b = @b.send(methodname, *args)
		
#		if methodname == :describe
#			return a
#		end
		
		if a.kind_of? MatchData
			if a.to_a != b.to_a
				puts "called: #{methodname}(#{args})"
				puts "Matchdata:\na = #{a.to_a.inspect}\nb = #{b.to_a.inspect}"
				puts "AFTER: "+@a.describe
				puts "AFTER: "+@b.describe
				puts "BEFORE: "+a_bef
				puts "BEFORE: "+b_bef
				puts caller.join("\n")
				exit
			end
		else
			if a!=b
				puts "called: #{methodname}(#{args})"
				puts "Attenzione!\na = #{a.inspect}\nb = #{b.inspect}"
				puts ""+@a.describe
				puts ""+@b.describe
				puts caller.join("\n")
				exit
			end
		end
		
		if @a.cur_char != @b.cur_char
			puts "Fuori sincronia dopo #{methodname}(#{args})"
			puts ""+@a.describe
			puts ""+@b.describe
			exit
		end
		
		return a
	end
end

end end end end
