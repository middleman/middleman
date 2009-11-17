Simple test for emphasis.
*** Parameters: ***
{}
*** Markdown input: ***
*Hello!* how are **you**?
*** Output of inspect ***
md_el(:document,[md_par([md_em(["Hello!"]), " how are ", md_strong(["you"]), "?"])],{},[])
*** Output of to_html ***
<p><em>Hello!</em> how are <strong>you</strong>?</p>
*** Output of to_latex ***
\emph{Hello!} how are \textbf{you}?
*** Output of to_md ***
Hello!how are you?
*** Output of to_s ***
Hello! how are you?
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)