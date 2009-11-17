
*** Parameters: ***
require 'maruku/ext/math'
{:math_numbered => ['\\['], :html_math_engine => 'itex2mml' }
*** Markdown input: ***

\[
	\alpha
\]

\begin{equation}
	\alpha
\end{equation}

\begin{equation} \beta
\end{equation}


\begin{equation} \gamma \end{equation}
*** Output of inspect ***
md_el(:document,[
	md_el(:equation,[],{:label=>"eq1",:math=>"\t\\alpha\n\n",:num=>1},[]),
	md_el(:equation,[],{:label=>nil,:math=>"\t\\alpha\n\n",:num=>nil},[]),
	md_el(:equation,[],{:label=>nil,:math=>" \\beta\n",:num=>nil},[]),
	md_el(:equation,[],{:label=>nil,:math=>" \\gamma ",:num=>nil},[])
],{},[])
*** Output of to_html ***
<div class='maruku-equation' id='eq:eq1'><math class='maruku-mathml' display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>&alpha;</mi></math><span class='maruku-eq-tex'><code style='display: none'>\alpha</code></span><span class='maruku-eq-number'>(1)</span></div><div class='maruku-equation'><math class='maruku-mathml' display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>&alpha;</mi></math><span class='maruku-eq-tex'><code style='display: none'>\alpha</code></span></div><div class='maruku-equation'><math class='maruku-mathml' display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>&beta;</mi></math><span class='maruku-eq-tex'><code style='display: none'>\beta</code></span></div><div class='maruku-equation'><math class='maruku-mathml' display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>&gamma;</mi></math><span class='maruku-eq-tex'><code style='display: none'>\gamma</code></span></div>
*** Output of to_latex ***
\begin{equation}
\alpha
\label{eq1}\end{equation}
\begin{displaymath}
\alpha
\end{displaymath}
\begin{displaymath}
\beta
\end{displaymath}
\begin{displaymath}
\gamma
\end{displaymath}
*** Output of to_md ***

*** Output of to_s ***

*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)