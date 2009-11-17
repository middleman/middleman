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

#
# NOTA BENE: 
#
# The following algorithm is a rip-off of RubyPants written by 
# Christian Neukirchen. 
#
# RubyPants is a Ruby port of SmartyPants written by John Gruber.
#
# This file is distributed under the GPL, which I guess is compatible
# with the terms of the RubyPants license.
#
# -- Andrea Censi


# = RubyPants -- SmartyPants ported to Ruby
#
# Ported by Christian Neukirchen <mailto:chneukirchen@gmail.com>
#   Copyright (C) 2004 Christian Neukirchen
#
# Incooporates ideas, comments and documentation by Chad Miller
#   Copyright (C) 2004 Chad Miller
#
# Original SmartyPants by John Gruber
#   Copyright (C) 2003 John Gruber
#

#
# = RubyPants -- SmartyPants ported to Ruby
#
#
# [snip]
#
# == Authors
# 
# John Gruber did all of the hard work of writing this software in
# Perl for Movable Type and almost all of this useful documentation.
# Chad Miller ported it to Python to use with Pyblosxom.
#
# Christian Neukirchen provided the Ruby port, as a general-purpose
# library that follows the *Cloth API.
# 
#
# == Copyright and License
# 
# === SmartyPants license:
# 
# Copyright (c) 2003 John Gruber
# (http://daringfireball.net)
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.
# 
# * Neither the name "SmartyPants" nor the names of its contributors
#   may be used to endorse or promote products derived from this
#   software without specific prior written permission.
# 
# This software is provided by the copyright holders and contributors
# "as is" and any express or implied warranties, including, but not
# limited to, the implied warranties of merchantability and fitness
# for a particular purpose are disclaimed. In no event shall the
# copyright owner or contributors be liable for any direct, indirect,
# incidental, special, exemplary, or consequential damages (including,
# but not limited to, procurement of substitute goods or services;
# loss of use, data, or profits; or business interruption) however
# caused and on any theory of liability, whether in contract, strict
# liability, or tort (including negligence or otherwise) arising in
# any way out of the use of this software, even if advised of the
# possibility of such damage.
# 
# === RubyPants license
# 
# RubyPants is a derivative work of SmartyPants and smartypants.py.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.
# 
# This software is provided by the copyright holders and contributors
# "as is" and any express or implied warranties, including, but not
# limited to, the implied warranties of merchantability and fitness
# for a particular purpose are disclaimed. In no event shall the
# copyright owner or contributors be liable for any direct, indirect,
# incidental, special, exemplary, or consequential damages (including,
# but not limited to, procurement of substitute goods or services;
# loss of use, data, or profits; or business interruption) however
# caused and on any theory of liability, whether in contract, strict
# liability, or tort (including negligence or otherwise) arising in
# any way out of the use of this software, even if advised of the
# possibility of such damage.
# 
#
# == Links
#
# John Gruber:: http://daringfireball.net
# SmartyPants:: http://daringfireball.net/projects/smartypants
#
# Chad Miller:: http://web.chad.org
#
# Christian Neukirchen:: http://kronavita.de/chris


module MaRuKu; module In; module Markdown; module SpanLevelParser
	Punct_class = '[!"#\$\%\'()*+,\-.\/:;<=>?\@\[\\\\\]\^_`{|}~]'
	Close_class = %![^\ \t\r\n\\[\{\(\-]!

	Rules = [
		[/---/,   :mdash          ],
		[/--/,    :ndash          ],
		['...',   :hellip         ],
		['. . .', :hellip         ],
		["``",    :ldquo          ],
		["''",    :rdquo          ],
		[/<<\s/,  [:laquo, :nbsp] ],
		[/\s>>/,  [:nbsp, :raquo] ],
		[/<</,    :laquo          ],
		[/>>/,    :raquo          ],
		
#		def educate_single_backticks(str)
#		["`", :lsquo]
#		["'", :rsquo]

		# Special case if the very first character is a quote followed by
		# punctuation at a non-word-break. Close the quotes by brute
		# force:
		[/^'(?=#{Punct_class}\B)/, :rsquo],
		[/^"(?=#{Punct_class}\B)/, :rdquo],
		# Special case for double sets of quotes, e.g.:
		#   <p>He said, "'Quoted' words in a larger quote."</p>
		[/"'(?=\w)/, [:ldquo, :lsquo]    ],
		[/'"(?=\w)/, [:lsquo, :ldquo]    ],
		# Special case for decade abbreviations (the '80s):
		[/'(?=\d\ds)/, :rsquo            ],
		# Get most opening single quotes:
		[/(\s)'(?=\w)/, [:one, :lsquo]   ],
		# Single closing quotes:
		[/(#{Close_class})'/, [:one, :rsquo]],
		[/'(\s|s\b|$)/, [:rsquo, :one]],
		# Any remaining single quotes should be opening ones:
		[/'/, :lsquo],
		# Get most opening double quotes:
		[/(\s)"(?=\w)/, [:one, :ldquo]],
		# Double closing quotes:
		[/(#{Close_class})"/, [:one, :rdquo]],
		[/"(\s|s\b|$)/, [:rdquo, :one]],
		# Any remaining quotes should be opening ones:
		[/"/, :ldquo]
	].
	map{|reg, subst| # People should do the thinking, machines should do the work.
		reg = Regexp.new(Regexp.escape(reg)) if not reg.kind_of? Regexp
		subst = [subst] if not subst.kind_of?Array
		[reg, subst]}

# note: input will be destroyed
def apply_one_rule(reg, subst, input)
	output = []
	while first = input.shift
		if first.kind_of?(String) && (m = reg.match(first))
			output.push    m. pre_match if m. pre_match.size > 0
			 input.unshift m.post_match if m.post_match.size > 0
			subst.reverse.each do |x|
				input.unshift( x == :one ? m[1] : md_entity(x.to_s) ) end
		else
			output.push first
		end
	end
	return output
end
	
def educate(elements)
	Rules.each do |reg, subst|
		elements = apply_one_rule(reg, subst, elements)
	end
	# strips empty strings
	elements.delete_if {|x| x.kind_of?(String) && x.size == 0}
	final = []
	# join consecutive strings
	elements.each do |x|
		if x.kind_of?(String) && final.last.kind_of?(String)
			final.last << x
		else
			final << x
		end
	end
	return final
end

end end end end
