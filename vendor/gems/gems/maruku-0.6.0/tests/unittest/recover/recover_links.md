This shows how Maruku recovers from parsing errors
*** Parameters: ***
{:on_error=>:warning}
*** Markdown input: ***
Search on [Google images][ 	GoOgle search ]
*** Output of inspect ***
md_el(:document,[md_par(["Search on ", md_link(["Google images"],"google_search")])],{},[])
*** Output of to_html ***
<p>Search on <span>Google images</span></p>
*** Output of to_latex ***
Search on Google images
*** Output of to_md ***
Search on Google images
*** Output of to_s ***
Search on Google images
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)