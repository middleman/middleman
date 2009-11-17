
require 'tempfile'
require 'fileutils'
require 'digest/md5'
require 'pstore'

module MaRuKu; module Out; module HTML
	
	PNG = Struct.new(:src,:depth,:height)
	
	def convert_to_png_blahtex(kind, tex)
		begin
			FileUtils::mkdir_p get_setting(:html_png_dir)

			# first, we check whether this image has already been processed
			md5sum = Digest::MD5.hexdigest(tex+" params: ")
			result_file = File.join(get_setting(:html_png_dir), md5sum+".txt")

			if not File.exists?(result_file) 
				tmp_in = Tempfile.new('maruku_blahtex')
				f = tmp_in.open
				f.write tex
				f.close

				resolution = get_setting(:html_png_resolution)

				options = "--png --use-preview-package --shell-dvipng 'dvipng -D #{resolution}' "
				options += "--displaymath " if kind == :equation
				options += ("--temp-directory '%s' " % get_setting(:html_png_dir))
				options += ("--png-directory '%s'" % get_setting(:html_png_dir))

				cmd = "blahtex #{options} < #{tmp_in.path} > #{result_file}"
				#$stderr.puts "$ #{cmd}"
        system cmd
				tmp_in.delete
			end
			
      result = File.read(result_file)
      if result.nil? || result.empty?
        raise "Blahtex error: empty output"
      end
      
			doc = Document.new(result, {:respect_whitespace =>:all})
			png = doc.root.elements[1]
			if png.name != 'png'
				raise "Blahtex error: \n#{doc}"
			end
			depth = png.elements['depth'] || (raise "No depth element in:\n #{doc}")
			height = png.elements['height'] || (raise "No height element in:\n #{doc}")
			md5 = png.elements['md5'] || (raise "No md5 element in:\n #{doc}")
			
			depth = depth.text.to_f
			height = height.text.to_f # XXX check != 0
			md5 = md5.text
			
			dir_url = get_setting(:html_png_url)
			return PNG.new("#{dir_url}#{md5}.png", depth, height)
		rescue Exception => e
			maruku_error "Error: #{e}"
		end
		nil
	end

  
	def convert_to_mathml_blahtex(kind, tex)
    @@BlahtexCache = PStore.new(get_setting(:latex_cache_file))
    
		begin
			@@BlahtexCache.transaction do 
				if @@BlahtexCache[tex].nil?
					tmp_in = Tempfile.new('maruku_blahtex')
						f = tmp_in.open
						f.write tex
						f.close
					tmp_out = Tempfile.new('maruku_blahtex')
	
					options = "--mathml"
					cmd = "blahtex #{options} < #{tmp_in.path} > #{tmp_out.path}"
					#$stderr.puts "$ #{cmd}"
					system cmd
					tmp_in.delete
					
					result = nil
					File.open(tmp_out.path) do |f| result=f.read end
						puts result
					
          @@BlahtexCache[tex] = result
				end
			
				blahtex = @@BlahtexCache[tex]
				doc = Document.new(blahtex, {:respect_whitespace =>:all})
				mathml = doc.root.elements['mathml']
				if not mathml
					maruku_error "Blahtex error: \n#{doc}"
					return nil
				else
					return mathml
				end
			end
			
		rescue Exception => e
			maruku_error "Error: #{e}"
		end
		nil
	end

end end end
