Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***
*   A list item with a blockquote:

    > This is a blockquote
    > inside a list item.

*** Output of inspect ***
md_el(:document,[
	md_el(:ul,[
		md_el(:li,[
			md_par(["A list item with a blockquote:"]),
			md_el(:quote,[md_par(["This is a blockquote inside a list item."])],{},[])
		],{:want_my_paragraph=>true},[])
	],{},[])
],{},[])
*** Output of to_html ***
<ul>
<li>
<p>A list item with a blockquote:</p>

<blockquote>
<p>This is a blockquote inside a list item.</p>
</blockquote>
</li>
</ul>
*** Output of to_latex ***
\begin{itemize}%
\item A list item with a blockquote:

\begin{quote}%
This is a blockquote inside a list item.


\end{quote}


\end{itemize}
*** Output of to_md ***
- list item with a blockquote:
This is a blockquote inside a list
item.
*** Output of to_s ***
A list item with a blockquote:This is a blockquote inside a list item.
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)