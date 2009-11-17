require 'maruku'

text = <<EOF
Chapter 1
=========

It was a stormy and rainy night.

EOF

invalid = <<EOF

This is a [bad link.

EOF

Maruku.new(text).to_html

s = ""

begin 
	Maruku.new(invalid, {:on_error => :raise, :error_stream => s})
	puts "Error! It should have thrown an exception."
rescue
	# puts "ok, got error"
end

begin 
	Maruku.new(invalid, {:on_error => :warning, :error_stream => s})
rescue
	puts "Error! It should not have thrown an exception."
end

