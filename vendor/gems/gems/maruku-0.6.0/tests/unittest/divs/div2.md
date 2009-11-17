Write a comment here
*** Parameters: ***
require 'maruku/ext/div'; {} # params 
*** Markdown input: ***
+--
ciao
=--
*** Output of inspect ***
md_el(:document,[
	md_el(:div,[md_par(["ciao"])],{:label=>nil,:num=>nil,:type=>nil},[])
],{},[])
*** Output of to_html ***
<div>
<p>ciao</p>
</div>
*** Output of to_latex ***
ciao
*** Output of to_md ***
ciao
*** Output of to_s ***
ciao
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)