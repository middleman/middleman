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
	Version = '0.6.0'
	
	MarukuURL = 'http://maruku.rubyforge.org/'
	
	# If true, use also PHP Markdown extra syntax
	#
	# Note: it is not guaranteed that if it's false
	# then no special features will be used.
	#
	# So please, ignore it for now.
	def markdown_extra?
		true
	end
	
	def new_meta_data?
		true
	end
	
end
