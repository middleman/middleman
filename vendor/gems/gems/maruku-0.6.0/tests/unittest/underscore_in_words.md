Note that Markdown.pl gives incorrect result here.
*** Parameters: ***
{} # params 
*** Markdown input: ***
Ok, this_was a_really_old bug
*** Output of inspect ***
md_el(:document,[md_par(["Ok, this_was a_really_old bug"])],{},[])
*** Output of to_html ***
<p>Ok, this_was a_really_old bug</p>
*** Output of to_latex ***
Ok, this\_was a\_really\_old bug
*** Output of to_md ***
Ok, this_was a_really_old bug
*** Output of to_s ***
Ok, this_was a_really_old bug
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)