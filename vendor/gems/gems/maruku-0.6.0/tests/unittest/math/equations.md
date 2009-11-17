Write a comment here
*** Parameters: ***
require 'maruku/ext/math';{}
*** Markdown input: ***

$$ x = y $$

$$ x 
= y $$

$$ 
x = y $$

$$ x = y 
$$

*** Output of inspect ***
md_el(:document,[
	md_el(:equation,[],{:label=>nil,:math=>" x = y ",:num=>nil},[]),
	md_el(:equation,[],{:label=>nil,:math=>" x = y \n",:num=>nil},[]),
	md_el(:equation,[],{:label=>nil,:math=>" x = y \n",:num=>nil},[]),
	md_el(:equation,[],{:label=>nil,:math=>" x = y \n",:num=>nil},[])
],{},[])
*** Output of to_html ***
<div class='maruku-equation'><code class='maruku-mathml'> x = y </code><div class='maruku-eq-tex'><code style='display: none'>x = y</code></div></div><div class='maruku-equation'><code class='maruku-mathml'> x = y 
</code><div class='maruku-eq-tex'><code style='display: none'>x = y</code></div></div><div class='maruku-equation'><code class='maruku-mathml'> x = y 
</code><div class='maruku-eq-tex'><code style='display: none'>x = y</code></div></div><div class='maruku-equation'><code class='maruku-mathml'> x = y 
</code><div class='maruku-eq-tex'><code style='display: none'>x = y</code></div></div>
*** Output of to_latex ***
\begin{displaymath}
x = y
\end{displaymath}
\begin{displaymath}
x = y
\end{displaymath}
\begin{displaymath}
x = y
\end{displaymath}
\begin{displaymath}
x = y
\end{displaymath}
*** Output of to_md ***

*** Output of to_s ***

*** EOF ***




Failed tests:   [:to_html] 

*** Output of inspect ***
md_el(:document,[
	md_el(:equation,[],{:label=>nil,:math=>" x = y ",:num=>nil},[]),
	md_el(:equation,[],{:label=>nil,:math=>" x = y \n",:num=>nil},[]),
	md_el(:equation,[],{:label=>nil,:math=>" x = y \n",:num=>nil},[]),
	md_el(:equation,[],{:label=>nil,:math=>" x = y \n",:num=>nil},[])
],{},[])
*** Output of to_html ***
-----| WARNING | -----
<div class='maruku-equation'><code class='maruku-mathml'> x = y </code><span class='maruku-eq-tex'><code style='display: none'>x = y</code></span></div><div class='maruku-equation'><code class='maruku-mathml'> x = y 
</code><span class='maruku-eq-tex'><code style='display: none'>x = y</code></span></div><div class='maruku-equation'><code class='maruku-mathml'> x = y 
</code><span class='maruku-eq-tex'><code style='display: none'>x = y</code></span></div><div class='maruku-equation'><code class='maruku-mathml'> x = y 
</code><span class='maruku-eq-tex'><code style='display: none'>x = y</code></span></div>
*** Output of to_latex ***
\begin{displaymath}
x = y
\end{displaymath}
\begin{displaymath}
x = y
\end{displaymath}
\begin{displaymath}
x = y
\end{displaymath}
\begin{displaymath}
x = y
\end{displaymath}
*** Output of to_md ***

*** Output of to_s ***

*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)