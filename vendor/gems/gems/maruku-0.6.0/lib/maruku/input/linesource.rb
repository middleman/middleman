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


module MaRuKu; module In; module Markdown; module BlockLevelParser

# This represents a source of lines that can be consumed.
#
# It is the twin of CharSource.
#
	
class LineSource
	include MaRuKu::Strings
	attr_reader :parent
	
	def initialize(lines, parent=nil, parent_offset=nil)
		raise "NIL lines? " if not lines
		@lines = lines
		@lines_index = 0
		@parent = parent
		@parent_offset = parent_offset
	end
	
	def cur_line()  @lines[@lines_index] end
	def next_line() @lines[@lines_index+1] end
		
	def shift_line() 
		raise "Over the rainbow" if @lines_index >= @lines.size 
		l = @lines[@lines_index]
		@lines_index += 1
		return l
	end
	
	def ignore_line
		raise "Over the rainbow" if @lines_index >= @lines.size 
		@lines_index += 1
	end
	
	def describe
		s = "At line #{original_line_number(@lines_index)}\n"
		
		context = 3 # lines
		from = [@lines_index-context, 0].max
		to   = [@lines_index+context, @lines.size-1].min
		
		for i in from..to
			prefix = (i == @lines_index) ? '--> ' : '    ';
			l = @lines[i]
			s += "%10s %4s|%s" %
				[@lines[i].md_type.to_s, prefix, l]
				
			s += "|\n"
		end
		
#		if @parent 
#			s << "Parent context is: \n"
#			s << add_tabs(@parent.describe,1,'|')
#		end
		s
	end
	
	def original_line_number(index)
		if @parent
			return index + @parent.original_line_number(@parent_offset)
		else
			1 + index
		end
	end
	
	def cur_index
		@lines_index
	end
	
	# Returns the type of next line as a string
	# breaks at first :definition
	def tell_me_the_future
		s = ""; num_e = 0;
		for i in @lines_index..@lines.size-1
			c = case @lines[i].md_type
				when :text; "t"
				when :empty; num_e+=1; "e"
				when :definition; "d"
				else "o"
			end
			s += c
			break if c == "d" or num_e>1
		end
		s	
	end
	
end # linesource

end end end end # block

