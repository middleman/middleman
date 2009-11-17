Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***
This is a list:
* one
* two

This is not a list:
* one
ciao

This is a list:
1. one
1. two

This is not a list:
1987. one
ciao

*** Output of inspect ***
md_el(:document,[
	md_par(["This is a list:"]),
	md_el(:ul,[
		md_el(:li_span,["one"],{:want_my_paragraph=>false},[]),
		md_el(:li_span,["two"],{:want_my_paragraph=>false},[])
	],{},[]),
	md_par(["This is not a list: * one ciao"]),
	md_par(["This is a list:"]),
	md_el(:ol,[
		md_el(:li_span,["one"],{:want_my_paragraph=>false},[]),
		md_el(:li_span,["two"],{:want_my_paragraph=>false},[])
	],{},[]),
	md_par(["This is not a list: 1987. one ciao"])
],{},[])
*** Output of to_html ***
<p>This is a list:</p>

<ul>
<li>one</li>

<li>two</li>
</ul>

<p>This is not a list: * one ciao</p>

<p>This is a list:</p>

<ol>
<li>one</li>

<li>two</li>
</ol>

<p>This is not a list: 1987. one ciao</p>
*** Output of to_latex ***
This is a list:

\begin{itemize}%
\item one
\item two

\end{itemize}
This is not a list: * one ciao

This is a list:

\begin{enumerate}%
\item one
\item two

\end{enumerate}
This is not a list: 1987. one ciao
*** Output of to_md ***
This is a list:

-ne
-wo

This is not a list: * one ciao

This is a list:

1.  one
2.  two

This is not a list: 1987. one ciao
*** Output of to_s ***
This is a list:onetwoThis is not a list: * one ciaoThis is a list:onetwoThis is not a list: 1987. one ciao
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)