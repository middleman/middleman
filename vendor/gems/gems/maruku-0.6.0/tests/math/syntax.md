LaTeX preamble: preamble.tex
CSS: math.css

Here are some formulas:

*	$\alpha$
*	$x^{n}+y^{n} \neq z^{n}$

Some inline maths: $\sum_{n=1}^\infty \frac{(-1)^n}{n} = \ln 2$. 

Some display  maths:

\[ \sum_{n=1}^\infty \frac{1}{n} \]
\[ \sum_{n=1}^\infty \frac{1}{n} \text{ is divergent, but } \lim_{n \to \infty} \sum_{i=1}^n \frac{1}{i} - \ln n \text{ exists.} \]     (a)

Some random AMSTeX symbols - thanks to Robin Snader for adding these:

$$ \beth \Subset \bigtriangleup \smallsmile \bumpeq \ggg \pitchfork $$ 

Note that $\hat g$ , $J$, and $\gamma_1\gamma_2$ all restrict to

$x_1 \overline{x_2} \oplus x_2 \overline{x_1}$ and that this module
is linear in $x_1$ and $x_2$.

See label \eqref{a}.

$$ \href{#hello}{\alpha+\beta} $$

## Cross references ##

The following are 4 equations, labeled A,B,C,D:

$$ \alpha $$ (A)

\[ 
	\beta
\] (B) 

$$ \gamma \label{C} $$

\[ 
	\delta \label{D}
\]

You can now refer to (eq:A), (eq:B), \eqref{C}, \eqref{D}.

