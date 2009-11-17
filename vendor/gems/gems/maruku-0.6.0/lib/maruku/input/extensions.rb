module MaRuKu; module In; module Markdown


	# Hash Fixnum -> name
	SpanExtensionsTrigger = {}
	
	
	class SpanExtension
		# trigging chars
		attr_accessor :chars
		# trigging regexp
		attr_accessor :regexp
		# lambda
		attr_accessor :block
	end
	
	# Hash String -> Extension
	SpanExtensions = {}

	def check_span_extensions(src, con)
		c = src.cur_char
		if extensions = SpanExtensionsTrigger[c]
			extensions.each do |e|
				if e.regexp && (match = src.next_matches(e.regexp))
					return true if e.block.call(doc, src, con)
				end
			end
		end
		return false # not special
	end
	
	def self.register_span_extension(args)
		e = SpanExtension.new
		e.chars = [*args[:chars]]
		e.regexp = args[:regexp]
		e.block = args[:handler] || raise("No blocks passed")
		e.chars.each do |c|
			(SpanExtensionsTrigger[c] ||= []).push e
		end
	end

	def self.register_block_extension(args)
		regexp = args[:regexp]
		BlockExtensions[regexp] = (args[:handler] || raise("No blocks passed"))
	end

	# Hash Regexp -> Block
	BlockExtensions = {}

	def check_block_extensions(src, con, line)
		BlockExtensions.each do |reg, block|
			if m = reg.match(line)
				block = BlockExtensions[reg]
				accepted =  block.call(doc, src, con)
				return true if accepted
			end
		end
		return false # not special
	end
	
	def any_matching_block_extension?(line)
		BlockExtensions.each_key do |reg|
			m = reg.match(line)
			return m if m
		end
		return false
	end
	
end end end
