Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***

The HTML specification is maintained by the W3C.

*[HTML]: Hyper Text Markup Language
*[W3C]:  World Wide Web Consortium



Operation Tigra Genesis is going well.

*[Tigra Genesis]:
*** Output of inspect ***
md_el(:document,[
	md_par([
		"The ",
		md_el(:abbr,["HTML"],{:title=>"Hyper Text Markup Language"},[]),
		" specification is maintained by the ",
		md_el(:abbr,["W3C"],{:title=>"World Wide Web Consortium"},[]),
		"."
	]),
	md_el(:abbr_def,[],{:abbr=>"HTML",:text=>"Hyper Text Markup Language"},[]),
	md_el(:abbr_def,[],{:abbr=>"W3C",:text=>"World Wide Web Consortium"},[]),
	md_par([
		"Operation ",
		md_el(:abbr,["Tigra Genesis"],{:title=>nil},[]),
		" is going well."
	]),
	md_el(:abbr_def,[],{:abbr=>"Tigra Genesis",:text=>nil},[])
],{},[])
*** Output of to_html ***
<p>The <abbr title='Hyper Text Markup Language'>HTML</abbr> specification is maintained by the <abbr title='World Wide Web Consortium'>W3C</abbr>.</p>

<p>Operation <abbr>Tigra Genesis</abbr> is going well.</p>
*** Output of to_latex ***
The HTML specification is maintained by the W3C.

Operation Tigra Genesis is going well.
*** Output of to_md ***
The HTMLspecification is maintained by
the W3C.

*[HTML]: Hyper Text Markup Language
*[W3C]: World Wide Web Consortium
Operation Tigra Genesisis going well.

*[Tigra Genesis]:
*** Output of to_s ***
The HTML specification is maintained by the W3C.Operation Tigra Genesis is going well.
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)