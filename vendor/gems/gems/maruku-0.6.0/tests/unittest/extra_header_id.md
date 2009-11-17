Write a comment abouth the test here.
*** Parameters: ***
{:title=>"Header 1"}
*** Markdown input: ***
Header 1            {#header1}
========

Header 2            {#header2}
--------

### Header 3 ###      {#header3}

Then you can create links to different parts of the same document like this:

[Link back to header 1](#header1),
[Link back to header 2](#header2),
[Link back to header 3](#header3)

*** Output of inspect ***
md_el(:document,[
	md_el(:header,["Header 1"],{:level=>1},[[:id, "header1"]]),
	md_el(:header,["Header 2"],{:level=>2},[[:id, "header2"]]),
	md_el(:header,["Header 3"],{:level=>3},[[:id, "header3"]]),
	md_par([
		"Then you can create links to different parts of the same document like this:"
	]),
	md_par([
		md_im_link(["Link back to header 1"], "#header1", nil),
		", ",
		md_im_link(["Link back to header 2"], "#header2", nil),
		", ",
		md_im_link(["Link back to header 3"], "#header3", nil)
	])
],{},[])
*** Output of to_html ***
<h1 id='header1'>Header 1</h1>

<h2 id='header2'>Header 2</h2>

<h3 id='header3'>Header 3</h3>

<p>Then you can create links to different parts of the same document like this:</p>

<p><a href='#header1'>Link back to header 1</a>, <a href='#header2'>Link back to header 2</a>, <a href='#header3'>Link back to header 3</a></p>
*** Output of to_latex ***
\hypertarget{header1}{}\section*{{Header 1}}\label{header1}

\hypertarget{header2}{}\subsection*{{Header 2}}\label{header2}

\hypertarget{header3}{}\subsubsection*{{Header 3}}\label{header3}

Then you can create links to different parts of the same document like this:

\hyperlink{header1}{Link back to header 1}, \hyperlink{header2}{Link back to header 2}, \hyperlink{header3}{Link back to header 3}
*** Output of to_md ***
Header 1Header 2Header 3Then you can create links to different
parts of the same document like this:

Link back to header 1,
Link back to header 2,
Link back to header 3
*** Output of to_s ***
Header 1Header 2Header 3Then you can create links to different parts of the same document like this:Link back to header 1, Link back to header 2, Link back to header 3
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)