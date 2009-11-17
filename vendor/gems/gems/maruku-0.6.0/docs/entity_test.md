
List of symbols supported by Maruku
===================================

<?maruku
	MaRuKu::Out::Latex.need_entity_table

	all = []
	ENTITY_TABLE.each do |k, e|
		if k.kind_of? String
			all << (h=md_code("&#{e.html_entity};")) <<
				" " << md_entity(e.html_entity) <<
				" (" << (l=md_code(e.latex_string)) << ") \n" <<
				md_entity('nbsp')<<md_entity('nbsp')<<md_entity('nbsp')
				
			h.attributes[:code_background_color] = '#eef'
			l.attributes[:code_background_color] = '#ffe'
		end
	end
	@doc.children.push md_par(all)
			
?>

