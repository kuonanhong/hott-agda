
%include agda.fmt

Homotopy theory is the study of spaces by way of their points, paths
(between points), homotopies (paths or continuous deformations between
paths), homotopies between homotopies (paths between paths between
paths), and so on.  This area of mathematics can be developed
\emph{synthetically} by using the homotopy-theoretic structure of types
in Martin-L\"of type
theory~\citep{hofmann98groupoid,lumsdaine09omega,vandenberggarner10groupoids,awodeywarren09identity,warren08thesis,gambinogarner08id,voevodsky11wollic}.
Using principles inspired by these semantics, such as higher
inductive
types~\citep{lumsdaine+13hits,shulman11hitsblog,lumsdaine11hitsblog} and
Voevodsky's univalence
axiom~\citep{voevodsky11wollic,voevodsky+12simpluniv}, some aspects of
homotopy theory have been developed and formalized using the
Agda~\citep{norell07thesis} and Coq~\citep{inria06coqmanual} proof
assistants.  These include calculations of some homotopy groups of
spheres~\citep{ls13pi1s1,lb13pinsn,uf13hott-book}; constructions of the
Hopf fibration~\citep{uf13hott-book}, of covering
spaces~\citep{favonia14covering}, and of Eilenberg-MacLane
spaces~\citep{lf14emspace}; and proofs of the Freudenthal suspension
theorem~\citep{uf13hott-book}, the Blakers-Massey theorem, the van
Kampen theorem~\citep{uf13hott-book}, and the Mayer-Vietoris
theorem~\citep{cavallo14mayervietoris}.  Ideas from synthetic homotopy
theory have also been applied to represent the patch theories that arise
in version control using higher inductive
types~\citep{amlh14patch}.

Many of the results mentioned above were posed as challenge problems
during the 2012--2013 year on univalent foundations at the Institute for
Advanced Study.  One additional challenge problem from that year, which
was anticipated to be \emph{less} difficult than those listed above, was
\begin{quote}
Show that the higher inductive definition of the torus is equivalent to
a product of two circles.
\end{quote}

In homotopy type theory, the elements of a type correspond to points of
a space, and the equality proofs in a type correspond to paths (we write
|Path a b| for the equality type).  A higher inductive type for the
circle (see \citep{ls13pi1s1,uf13hott-book}) is generated by a point and a
loop.  The picture
\begin{center}
  \begin{tikzpicture}
    \node[circle,fill,inner sep=1.5pt,label=right:{|base|}] (base) at (0,0) {};
    \draw (base) arc (0:170:.6cm) node[anchor=south east] {|loop|} arc (170:360:.6cm);
  \end{tikzpicture}
\end{center}
corresponds to a higher inductive type with one point constructor and
one path constructor:
\begin{code}
base : S¹
loop : Path base base
\end{code}
Similarly, we can describe a torus (think of a donut or bagel) by
identifying the opposite sides of a square (glue two sides together to
form a cylinder, and then glue the two ends of the cylinder together):
\begin{center}
\begin{tikzpicture}
  \coordinate (ul) at (0,1);
  \coordinate (bl) at (0,0);
  \coordinate (br) at (1,0);
  \coordinate (ur) at (1,1);

  \node at (0.5,0.5) {|f|};
  \draw[->] (ul) to node[above] {|q|} (ur);
  \draw[->] (bl) to node[below] {|q|} (br);
  \draw[->] (ul) to node[left] {|p|} (bl);
  \draw[->] (ur) to node[right] {|p|} (br);
\end{tikzpicture}
\end{center}
Writing |p · q| for composition of paths in diagramatic order, the torus
can be represented by a higher inductive type with the following
constructors (see \citep[Section 6.6]{uf13hott-book}):
\begin{code}
a : T
p : Path a a
q : Path a a
f : Path (p · q) (q · p)
\end{code}
The |f| (``face'') constructor generates a path between paths.  It
represents the inside of the above square as a disc between the ``left
then bottom'' and ``top then right'' composites.  Algebraically, the
torus is generated by two commuting loops.

To prove that the torus is equivalent to the product of two circles
means to give functions |t2c : T → S¹ × S¹| and |c2t : S¹ × S¹ → T| and
show that they are mutually inverse (up to paths).  At first glance, it
seems like it should be simple to define the functions back and forth
and prove that they are mutually inverse using the recursion and
induction principles for the circle and the torus. And indeed, it is not
difficult to define the two functions.  However, at the end of the IAS
year, this problem had not been solved, though Sojakova and Lumsdaine
had each given proof sketches, and Sojakova's later appeared as a
25-page proof in the exercise solutions for the homotopy type theory
book~\citep{uf13hott-book}.  The reason for the complexity is that the
path manipulation required to prove the path-between-path goals gets
quite involved.

In this paper, we develop a cubical approach to synthetic homotopy
theory.  Using this approach and the libraries we develop, the proof
that the torus is the product of two circles can be formalized in Agda
in around 100 lines of code.\footnote{The Agda code is in
github.com/dlicata335/hott-agda.  See lib/cubical/ and homotopy/TS1S1.agda} The approach has also proved
useful for the formalization of a ``three-by-three'' lemma about
pushouts that is used in the construction of the Hopf fibration,\footnote{The Agda code will be in github.com/HoTT/HoTT-Agda} and
in resolving a question~\citep{amlh14patch} about a patch theory
represented as a higher inductive type.  The approach was also used by
Cavallo to simplify the proof of the Mayer-Vietoris
theorem~\citep{cavallo14mayervietoris}.

Inspired by heterogeneous equality~\citep{mcbride00thesis} and the
cubical sets model of type theory~\citep{coquand+13cubical}, the main
idea of the approach is to work with \emph{cube types} that generalize
the path type |Path a b|.  For example, in this paper, we will consider
a type of squares |Square l t b r|, dependent on four paths that fit
into a square:
\begin{center}
\begin{tikzpicture}
  \coordinate (ul) at (0,1);
  \coordinate (bl) at (0,0);
  \coordinate (br) at (1,0);
  \coordinate (ur) at (1,1);

  \node[circle,draw,inner sep=1.5pt,label=left:{|a00|}] (base) at (ul) {};
  \node[circle,draw,inner sep=1.5pt,label=left:{|a01|}] (base) at (bl) {};
  \node[circle,draw,inner sep=1.5pt,label=right:{|a10|}] (base) at (ur) {};
  \node[circle,draw,inner sep=1.pt,label=right:{|a11|}] (base) at (br) {};
  \draw (ul) to node[above] {|t|} (ur);
  \draw (bl) to node[below] {|b|} (br);
  \draw (ul) to node[left] {|l|} (bl);
  \draw (ur) to node[right] {|r|} (br);
\end{tikzpicture}
\end{center}
%% For any type |A|, the square type is dependent on four points |a00|
%% |a01| |a10| |a11| of type |A| and four paths |l : Path a00 a01| and |r :
%% Path a10 a11| and |t : Path a00 a1| and |b : Path a01 a11|.  
We will also consider a type of cubes |Cube left right front top bot
back| dependent on six squares giving its sides.
Another key ingredient is to work systematically with path-over-a path
and higher cube-over-a-cube types to represent cubes in a dependent type.

While our approach fits nicely with work in progress on new cubical type
theories~\citep{lb14cubes-oxford,altenkirchkaposi14cubical,coquand14variations,polonsky14internalization}, the
present paper can be conducted entirely by making appropriate
definitions in Martin-L\"of type theory with axioms for univalence and higher
inductive types.  Higher cubes can
be defined in terms of higher paths, and 
%% : for example, the type of squares
%% considered above can be thought of as discs |Path (l · b) (t · r)|.
cube-over-a-cube types can be reduced to homogeneous paths.  Thus, our
constructions can be interpreted in the known models of homotopy type
theory with univalence and higher inductive types (see
\citep{voevodsky+12simpluniv,shulman13inversediag,lumsdaine+13hits}).
While cubes can be reduced away in this way, for engineering reasons, we
have found it convenient in Agda to use new inductive families to
represent cube types; this allows us to make more effective use of
dependent pattern matching and unification.

We begin by discussing a notion of heterogeneous equality
(Section~\ref{sec:heq}), and a related path-over-a-path type
(Section~\ref{sec:pathover}).  Then, we discuss squares
(Section~\ref{sec:square}) and cubes (Section~\ref{sec:cube}).  Next, we
discuss the torus example (Section~\ref{sec:torus}), and the 
three-by-three pushout lemma (Section~\ref{sec:threebythree}).

