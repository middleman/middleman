class String
	Textile2_EmptyLine = /^\s*$/
	Textile2_Signature = /^(\S+\.?)\.\s(.*)/

	def t2_empty?
		self =~ Textile2_EmptyLine
	end
	
	def t2_contains_signature?
		self =~ Textile2_Signature
	end
	
	# sig, rest = t2_get_signature
	def t2_get_signature
		self =~ Textile2_Signature
		return Textile2Signature.new($1), $2
	end
end

class Textile2Signature	
	Reg = %r{
		^
		# block name is 1
		([A-Za-z0-9]+)? 
		# style is 2
		(
		 \{     # open bracket
		   ([^\}]+) # style spec is 3   
		 \}     # close bracket
		)?      
		# language is 4
		(\[(\w+)\])? # value is 5
		# class and id 
		(?:
		 \(     # open par
		   (\w+)?   # optional class specification is 6
		   (?:\#(\w+))?  # optional id is 7
		 \)     # close par
		)?      
		# alignment is 8
		(\<|\>|\<\>|\=)?
		# padding 
		(\(+)? # left is 9
		(\)+)? # right is 10
		# filters is 11
		(\|      
			(?:(?:\w+)\|)+
		)?
		# optional final dot is 12
		(\.)?   
		$
	}x
	
	
	def initialize(s)
		if m = Reg.match(s)
			self.block_name = m[1]
			self.style = m[3]
			self.lang = m[4]
			self.css_class = m[6]
			self.css_id = m[7]
			self.text_align = {nil=>nil,'>'=>'right','<'=>'left',
				'<>'=>'center','='=>'justified'}[m[8]]
			self.num_left_pad = m[9] && m[9].size
			self.num_right_pad = m[10] && m[10].size
			self.filters = m[11] && m[11].split('|')
			self.double_dot = m[12] && true
		end
	end
	
	
	attr_accessor :block_name # or nil
	attr_accessor :style # or nil
	attr_accessor :lang  # or nil
	attr_accessor :css_class # or nil
	attr_accessor :css_id # or nil
	attr_accessor :text_align # {nil, 'left', 'right', 'center', 'justified'}
	attr_accessor :num_left_pad # nil or 1..
	attr_accessor :num_right_pad # nil or 1..
	attr_accessor :filters # nil [], array of strings
	attr_accessor :double_dot # nil or true
	
	
end

module MaRuKu
	
	def self.textile2(source, params)
		m = Maruku.new
		m.t2_parse(source, params)
	end
	
	
	class MDDocument
		def t2_parse(source, params)
			src = LineSource.new(source)
			output = BlockContext.new
			t2_parse_blocks(src, output)
			self.children = output.elements
		end
		
		Handling = Struct.new(:method, :parse_lines)
		T2_Handling = {
			nil => Handling.new(:t2_block_paragraph, true),
			'p' => Handling.new(:t2_block_paragraph, true)
		}
		
		# Input is a LineSource
		def t2_parse_blocks(src, output)
			while src.cur_line
				l = src.shift_line
				
				# ignore empty line
				if l.t2_empty? then 
					src.shift_line
					next 
				end
				
				# TODO: lists
				# TODO: xml
				# TODO: `==`

				signature, l =
					if l.t2_contains_signature?
						l.t2_get_signature
					else
						[Textile2Signature.new, l]
					end

				if handling = T2_Handling.has_key?(signature.block_name)
					if self.responds_to? handling.method
						# read as many non-empty lines that you can
						lines = [l]
						if handling.parse_lines
							while not src.cur_line.t2_empty?
								lines.push src.shift_line
							end
						end
					
						self.send(handling.method, src, output, signature, lines)
					else
						maruku_error("We don't know about method #{handling.method.inspect}")
						next
					end
				end
				
				
			end
		end
		
		def t2_block_paragraph(src, output, signature, lines)
			paragraph = lines.join("\n")
			src2 = CharSource.new(paragraph, src)
#			output = 
		end
		
		def t2_parse_span(src, output)
			
		end
		
	end # MDDocument
	
end