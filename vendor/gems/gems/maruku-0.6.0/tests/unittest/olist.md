
*** Parameters: ***
{}
*** Markdown input: ***
This is a list:

2. one
2. two
3. three
*** Output of inspect ***
md_el(:document,[
	md_par(["This is a list:"]),
	md_el(:ol,[
		md_el(:li_span,["one"],{:want_my_paragraph=>false},[]),
		md_el(:li_span,["two"],{:want_my_paragraph=>false},[]),
		md_el(:li_span,["three"],{:want_my_paragraph=>false},[])
	],{},[])
],{},[])
*** Output of to_html ***
<p>This is a list:</p>

<ol>
<li>one</li>

<li>two</li>

<li>three</li>
</ol>
*** Output of to_latex ***
This is a list:

\begin{enumerate}%
\item one
\item two
\item three

\end{enumerate}
*** Output of to_md ***
This is a list:

1.  one
2.  two
3.  three
*** Output of to_s ***
This is a list:onetwothree
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)