
=begin maruku_doc
Extension: math
Attribute: html_math_engine
Scope: document, element
Output: html
Summary: Select the rendering engine for MathML.
Default: <?mrk Globals[:html_math_engine].to_s ?>

Select the rendering engine for math.

If you want to use your custom engine `foo`, then set:

	HTML math engine: foo
{:lang=markdown}

and then implement two functions:

	def convert_to_mathml_foo(kind, tex)
		...
	end
=end

=begin maruku_doc
Extension: math
Attribute: html_png_engine
Scope: document, element
Output: html
Summary: Select the rendering engine for math.
Default: <?mrk Globals[:html_math_engine].to_s ?>

Same thing as `html_math_engine`, only for PNG output.

	def convert_to_png_foo(kind, tex)
		# same thing
		...
	end
{:lang=ruby}

=end

module MaRuKu; module Out; module HTML


	
	# Creates an xml Mathml document of self.math
	def render_mathml(kind, tex)
		engine = get_setting(:html_math_engine)
		method = "convert_to_mathml_#{engine}".to_sym
		if self.respond_to? method
			mathml = self.send(method, kind, tex) 
			return mathml || convert_to_mathml_none(kind, tex)
		else 
			puts "A method called #{method} should be defined."
			return convert_to_mathml_none(kind, tex)
		end
	end

	# Creates an xml Mathml document of self.math
	def render_png(kind, tex)
		engine = get_setting(:html_png_engine)
		method = "convert_to_png_#{engine}".to_sym
		if self.respond_to? method
			return self.send(method, kind, tex) 
		else 
			puts "A method called #{method} should be defined."
			return nil
		end
	end
	
	def pixels_per_ex
		if not $pixels_per_ex 
			x = render_png(:inline, "x")
			$pixels_per_ex  = x.height # + x.depth
		end
		$pixels_per_ex
	end
		
	def adjust_png(png, use_depth)
		src = png.src
		
		height_in_px = png.height
		depth_in_px = png.depth
		height_in_ex = height_in_px / pixels_per_ex
		depth_in_ex = depth_in_px / pixels_per_ex
		total_height_in_ex = height_in_ex + depth_in_ex
		style = "" 
		style += "vertical-align: -#{depth_in_ex}ex;" if use_depth
		style += "height: #{total_height_in_ex}ex;"
		img = Element.new 'img'
		img.attributes['src'] = src
		img.attributes['style'] = style
		img.attributes['alt'] = "$#{self.math.strip}$"
		img
	end
	
	def to_html_inline_math
		mathml  = get_setting(:html_math_output_mathml) && render_mathml(:inline, self.math)
		png = get_setting(:html_math_output_png) &&  render_png(:inline, self.math)

		span = create_html_element 'span'
		add_class_to(span, 'maruku-inline')
			
			if mathml
				add_class_to(mathml, 'maruku-mathml')
				return mathml
			end
	
			if png
				img = adjust_png(png, use_depth=true)
				add_class_to(img, 'maruku-png')
				span << img
			end
		span
		
	end

	def to_html_equation
		mathml  = get_setting(:html_math_output_mathml) && render_mathml(:equation, self.math)
		png     = get_setting(:html_math_output_png)    && render_png(:equation, self.math)
		
		div = create_html_element 'div'
		add_class_to(div, 'maruku-equation')
			if mathml
				add_class_to(mathml, 'maruku-mathml')
				div << mathml 
			end
			
			if png
				img = adjust_png(png, use_depth=false)
				add_class_to(img, 'maruku-png')
				div << img
			end
			
			source_span = Element.new 'span'
			add_class_to(source_span, 'maruku-eq-tex')
			code = convert_to_mathml_none(:equation, self.math.strip)	
			code.attributes['style'] = 'display: none'
			source_span << code
			div << source_span

			if self.label  # then numerate
				span = Element.new 'span'
				span.attributes['class'] = 'maruku-eq-number'
				num = self.num
				span << Text.new("(#{num})")
				div << span
				div.attributes['id'] = "eq:#{self.label}"
			end
		div
	end
	
	def to_html_eqref
		if eq = self.doc.eqid2eq[self.eqid]
			num = eq.num
			a = Element.new 'a'
			a.attributes['class'] = 'maruku-eqref'
			a.attributes['href'] = "#eq:#{self.eqid}"
			a << Text.new("(#{num})")
			a
		else
			maruku_error "Cannot find equation #{self.eqid.inspect}"
			Text.new "(eq:#{self.eqid})"
		end
	end

	def to_html_divref
		ref= nil
		self.doc.refid2ref.each_value { |h|
			ref = h[self.refid] if h.has_key?(self.refid)			
		}
		if ref
			num = ref.num
                        a = Element.new 'a'
                        a.attributes['class'] = 'maruku-ref'
                        a.attributes['href'] = "#" + self.refid
                        a << Text.new(num.to_s)
                        a
                else
                        maruku_error "Cannot find div #{self.refid.inspect}"
                        Text.new "\\ref{#{self.refid}}"
                end
	end
	
end end end


