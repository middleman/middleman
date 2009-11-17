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


module MaRuKu

class MDElement
	
	# Yields to each element of specified node_type
	# All elements if e_node_type is nil.
	def each_element(e_node_type=nil, &block) 
		@children.each do |c| 
			if c.kind_of? MDElement
				if (not e_node_type) || (e_node_type == c.node_type)
					block.call c
				end
				c.each_element(e_node_type, &block)
			end
		end
	end
	
	# Apply passed block to each String in the hierarchy.
	def replace_each_string(&block)
		for c in @children
			if c.kind_of? MDElement
				c.replace_each_string(&block)
			end
		end

		processed = []
		until @children.empty?
			c = @children.shift
			if c.kind_of? String
				result = block.call(c)
				[*result].each do |e| processed << e end
			else
				processed << c
			end
		end
		@children = processed
	end

end
end