%%%
%%% Method of analytic tableaux for a propositional logic
%%%

%%% Some useful boolean operators.
:- op(200, fy, non).
:- op(210, yfx, &).
:- op(220, yfx, v).
:- op(230, xfy, =>).
:- op(240, xfx, <=>).

%%% satisfiable(+Formulae)
%
%% Input: a set of formulas in the negative normal form,
% 	 variables are Prolog variables
% 	 (at the moment only 'not', 'and', 'or' are allowed, no implication)
%
%
%% Output: succeeds if the set of formulas is satisfiable, fails otherwise
%
%% Example: satisfiable(and(X, Y), not(X)) -> fail
satisfiable(Formulae) :-
	map(nnt, Formulae, FormulaeNNT),
	\+ closed_tableau(FormulaeNNT).

%%% tautology(+Formula)
%
%% Output: succeeds if the Formula is a tautogy, fails otherwise
%
%% Example:
% ?- tautology((X => (Y => Z)) => ((X => Y) => (X => Z))).
% X = Y, Y = Z, Z = continue.
tautology(Formula) :-
	nnt(non(Formula), NNT),
	closed_tableau([NNT]).

%%% ent(+Formula, -FormalaNNT)
%
%% Input: any formula of a propositional logic
%
%% Output: the formula converted into the NNT;
%	   it also takes care of implications and equivalences
%
%% Example:
% ?- nnt((X => (Y => Z)) => ((X => Y) => (X => Z)), NNT).
% NNT = X& (Y&non Z)v (X&non Y v (non X v Z)).
nnt(X, X) :-
	var(X),
	!.

nnt(non X, non X) :-
	var(X),
	!.

nnt(Phi, PhiNNT) :-
	nnt_b(Phi, PhiNNT),
	!.

nnt_b(Phi <=> Psi, NNT) :-
	nnt_b(Phi => Psi & Psi => Phi, NNT),
	!.

nnt_b(non(Phi <=> Psi), NNT) :-
	nnt_b(non(Phi => Psi & Psi => Phi), NNT),
	!.

nnt_b(Phi => Psi, NNT) :-
	nnt_b(non Phi v Psi, NNT),
	!.

nnt_b(non(Phi => Psi), NNT) :-
	nnt_b(non(non Phi v Psi), NNT),
	!.

nnt_b(non non Psi, PsiNNT) :-
	nnt(Psi, PsiNNT),
	!.

nnt_b(Phi & Psi, PhiNNT & PsiNNT) :-
	nnt(Phi, PhiNNT),
	nnt(Psi, PsiNNT),
	!.

nnt_b(non(Phi & Psi), PhiNNT v PsiNNT) :-
	nnt(non Phi, PhiNNT),
	nnt(non Psi, PsiNNT),
	!.

nnt_b(Phi v Psi, PhiNNT v PsiNNT) :-
	nnt(Phi, PhiNNT),
	nnt(Psi, PsiNNT),
	!.

nnt_b(non(Phi v Psi), PhiNNT & PsiNNT) :-
	nnt(non Phi, PhiNNT),
	nnt(non Psi, PsiNNT),
	!.

%%% map(+Function, +List, -MappedList)
%
% map function as we know it from functional programming;
% returns the list reversed, but that's not a problem for us

map(Function, List, MappedList) :-
	map(Function, List, [], MappedList).

map(_, [], Acc, Acc).
map(Function, [H|T], Acc, Res) :-
	F =..[Function, H, MH],
	call(F),
	map(Function, T, [MH|Acc], Res).

%%% closed_tableau(+Formulae)

% If an unbound variable is encountered, mark it as 'continue'.
% The next time we encounter it we see either 'continue' and we skip it,
% or we see 'not(continue)' and we close the branch.
closed_tableau([X|Set]) :-
	var(X),
	X = continue,
	closed_tableau(Set).

% Otherwise jump to the bound variables section.
closed_tableau([X|Set]) :-
	nonvar(X),
	closed_tableau_b([X|Set]).

%%% closed_tableau_b(+Formulae)
%
% closed_tableau for bound variables

% If we encounter 'stop', we just close the branch.
closed_tableau_b([stop|_]).

% If we encounter 'continue', we just skip it, because we have seen it already.
closed_tableau_b([continue|Set]) :-
	closed_tableau(Set).

%% NOT rule

% 'not(continue)' ~ 'stop'
closed_tableau_b([non continue|_]).

% If we encounter 'not(X)', we set X to stop, because the next time we see it,
% we can safely close the branch.
closed_tableau_b([non X|Set]) :-
	X = stop,
	closed_tableau(Set).

%% AND rule, just serialize the formulas.
closed_tableau_b([Phi & Psi|Set]) :- 
	closed_tableau([Phi,Psi|Set]).

%% OR rule, create a new branch.
closed_tableau_b([Phi v Psi|Set]) :-
	closed_tableau([Phi|Set]),
	closed_tableau([Psi|Set]).
