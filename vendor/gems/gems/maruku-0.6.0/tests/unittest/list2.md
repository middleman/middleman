Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***
*   This is a list item with two paragraphs.

    This is the second paragraph in the list item. You're
only required to indent the first line. Lorem ipsum dolor
sit amet, consectetuer adipiscing elit.

*   other

*** Output of inspect ***
md_el(:document,[
	md_el(:ul,[
		md_el(:li,[
			md_par(["This is a list item with two paragraphs."]),
			md_par([
				"This is the second paragraph in the list item. You",
				md_entity("rsquo"),
				"re only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit."
			])
		],{:want_my_paragraph=>true},[]),
		md_el(:li,[md_par(["other"])],{:want_my_paragraph=>false},[])
	],{},[])
],{},[])
*** Output of to_html ***
<ul>
<li>
<p>This is a list item with two paragraphs.</p>

<p>This is the second paragraph in the list item. You&#8217;re only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</p>
</li>

<li>
<p>other</p>
</li>
</ul>
*** Output of to_latex ***
\begin{itemize}%
\item This is a list item with two paragraphs.

This is the second paragraph in the list item. You'{}re only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.


\item other



\end{itemize}
*** Output of to_md ***
-This is a list item with two paragraphs.
This is the second paragraph in the list item. Youre only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
-ther
*** Output of to_s ***
This is a list item with two paragraphs.This is the second paragraph in the list item. Youre only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.other
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)