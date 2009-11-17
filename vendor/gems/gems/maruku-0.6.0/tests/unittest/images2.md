Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***

This is an ![image][].

This is an ![image].

[image]: image.jpg

*** Output of inspect ***
md_el(:document,[
	md_par(["This is an ", md_image(["image"], "image"), "."]),
	md_par(["This is an ", md_image(["image"], "image"), "."]),
	md_ref_def("image", "image.jpg", {:title=>nil})
],{},[])
*** Output of to_html ***
<p>This is an <img src='image.jpg' alt='image' />.</p>

<p>This is an <img src='image.jpg' alt='image' />.</p>
*** Output of to_latex ***
This is an .

This is an .
*** Output of to_md ***
This is an image.

This is an image.
*** Output of to_s ***
This is an image.This is an image.
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)