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
	
Globals = {
	:unsafe_features => false,
	:on_error => :warning,
	
	
	:use_numbered_headers => false,
	
	:maruku_signature => false,
	:code_background_color => '#fef',
	:code_show_spaces => false,
	
	:filter_html => false,
	
	:html_math_output_mathml => true, # also set :html_math_engine
	:html_math_engine => 'none', #ritex, itex2mml
	
	:html_math_output_png => false, 	
	:html_png_engine => 'none',
	:html_png_dir => 'pngs',
	:html_png_url => 'pngs/',
	:html_png_resolution => 200,
  
	:html_use_syntax => false,
	
	:latex_use_listings => false,
	:latex_cjk => false,
  :latex_cache_file  => "blahtex_cache.pstore", # cache file for blahtex filter
	
	:debug_keep_ials => false,
	:doc_prefix => ''
}

class MDElement
	def get_setting(sym)
		if self.attributes.has_key?(sym) then
			return self.attributes[sym]
		elsif self.doc && self.doc.attributes.has_key?(sym) then
			return self.doc.attributes[sym]
		elsif MaRuKu::Globals.has_key?(sym)
			return MaRuKu::Globals[sym]
		else
			$stderr.puts "Bug: no default for #{sym.inspect}"
			nil
		end
	end
end

end