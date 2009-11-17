Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***
This block is composed of three lines:

	one
	
	three

This block is composed of 5

	
	one
	
	
	four
	

This block is composed of 2

	 
	two



*** Output of inspect ***
md_el(:document,[
	md_par(["This block is composed of three lines:"]),
	md_el(:code,[],{:raw_code=>"one\n\nthree"},[]),
	md_par(["This block is composed of 5"]),
	md_el(:code,[],{:raw_code=>"one\n\n\nfour"},[]),
	md_par(["This block is composed of 2"]),
	md_el(:code,[],{:raw_code=>"two"},[])
],{},[])
*** Output of to_html ***
<p>This block is composed of three lines:</p>

<pre><code>one

three</code></pre>

<p>This block is composed of 5</p>

<pre><code>one


four</code></pre>

<p>This block is composed of 2</p>

<pre><code>two</code></pre>
*** Output of to_latex ***
This block is composed of three lines:

\begin{verbatim}one

three\end{verbatim}
This block is composed of 5

\begin{verbatim}one


four\end{verbatim}
This block is composed of 2

\begin{verbatim}two\end{verbatim}
*** Output of to_md ***
This block is composed of three lines:

This block is composed of 5

This block is composed of 2
*** Output of to_s ***
This block is composed of three lines:This block is composed of 5This block is composed of 2
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)