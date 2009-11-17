Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***
1. abcd
efgh
ijkl

*** Output of inspect ***
md_el(:document,[
	md_el(:ol,[md_el(:li_span,["abcd efgh ijkl"],{:want_my_paragraph=>false},[])],{},[])
],{},[])
*** Output of to_html ***
<ol>
<li>abcd efgh ijkl</li>
</ol>
*** Output of to_latex ***
\begin{enumerate}%
\item abcd efgh ijkl

\end{enumerate}
*** Output of to_md ***
1.  abcd efgh ijkl
*** Output of to_s ***
abcd efgh ijkl
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)