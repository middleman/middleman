Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***
**This bug is now solved**

Previously, a bug would not let you use `code` inside links text.

So this:
	Use the [`syntax`][syntax]
produces:
> Use the [`syntax`][syntax]

And this:
	Use the `[syntax][syntax]`
produces:
> Use the `[syntax][syntax]`

[syntax]: http://gogole.com


*** Output of inspect ***
md_el(:document,[
	md_par([md_strong(["This bug is now solved"])]),
	md_par([
		"Previously, a bug would not let you use ",
		md_code("code"),
		" inside links text."
	]),
	md_par([
		"So this: Use the ",
		md_link([md_code("syntax")],"syntax"),
		" produces:"
	]),
	md_el(:quote,[md_par(["Use the ", md_link([md_code("syntax")],"syntax")])],{},[]),
	md_par(["And this: Use the ", md_code("[syntax][syntax]"), " produces:"]),
	md_el(:quote,[md_par(["Use the ", md_code("[syntax][syntax]")])],{},[]),
	md_ref_def("syntax", "http://gogole.com", {:title=>nil})
],{},[])
*** Output of to_html ***
<p><strong>This bug is now solved</strong></p>

<p>Previously, a bug would not let you use <code>code</code> inside links text.</p>

<p>So this: Use the <a href='http://gogole.com'><code>syntax</code></a> produces:</p>

<blockquote>
<p>Use the <a href='http://gogole.com'><code>syntax</code></a></p>
</blockquote>

<p>And this: Use the <code>[syntax][syntax]</code> produces:</p>

<blockquote>
<p>Use the <code>[syntax][syntax]</code></p>
</blockquote>
*** Output of to_latex ***
\textbf{This bug is now solved}

Previously, a bug would not let you use {\colorbox[rgb]{1.00,0.93,1.00}{\tt code}} inside links text.

So this: Use the \href{http://gogole.com}{{\colorbox[rgb]{1.00,0.93,1.00}{\tt syntax}}} produces:

\begin{quote}%
Use the \href{http://gogole.com}{{\colorbox[rgb]{1.00,0.93,1.00}{\tt syntax}}}


\end{quote}
And this: Use the {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char91syntax\char93\char91syntax\char93}} produces:

\begin{quote}%
Use the {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char91syntax\char93\char91syntax\char93}}


\end{quote}
*** Output of to_md ***
This bug is now solved

Previously, a bug would not let you use
inside links text.

So this: Use the produces:

Use the

And this: Use the produces:

Use the
*** Output of to_s ***
This bug is now solvedPreviously, a bug would not let you use  inside links text.So this: Use the  produces:Use the And this: Use the  produces:Use the
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)