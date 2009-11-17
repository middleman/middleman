Write a comment here
*** Parameters: ***
require 'maruku/ext/div'; {} # params 
*** Markdown input: ***
+-----------------------------------{.warning}------
| this is the last warning!
|
| please, go away!
|
| +------------------------------------- {.menace} --
| | or else terrible things will happen
| +--------------------------------------------------
+---------------------------------------------------
*** Output of inspect ***
md_el(:document,[
	md_el(:div,[
		md_par(["this is the last warning!"]),
		md_par(["please, go away!"]),
		md_el(:div,[md_par(["or else terrible things will happen"])],{:label=>nil,:num=>nil,:type=>nil},[[:class, "menace"]])
	],{:label=>nil,:num=>nil,:type=>nil},[[:class, "warning"]])
],{},[])
*** Output of to_html ***
<div class='warning'>
<p>this is the last warning!</p>

<p>please, go away!</p>

<div class='menace'>
<p>or else terrible things will happen</p>
</div>
</div>
*** Output of to_latex ***
this is the last warning!

please, go away!

or else terrible things will happen
*** Output of to_md ***
this is the last warning!

please, go away!

or else terrible things will happen
*** Output of to_s ***
this is the last warning!please, go away!or else terrible things will happen
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)