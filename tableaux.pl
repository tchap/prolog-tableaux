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
% ?- tautology((X => X) & Y).
% Closing branch [1,non 1]
% Failed to close branch [non 2] -> FAIL
% X = continue 1,
% Y = stop 2.
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

map(_, [], Acc, Acc) :- !.
map(Function, [H|T], Acc, Res) :-
	F =..[Function, H, MH],
	call(F),
	map(Function, T, [MH|Acc], Res).

%%% closed_tableau(+Formulae)

:- op(190, fx, stop).
:- op(190, fx, continue).

closed_tableau(Formulae) :-
	b_setval(marker, 0),
	closed_tableau_([], Formulae).

% We failed to close a branch if there are no more formulas we can use.
closed_tableau_(Branch, []) :-
	format('Branch: ~w~n', [Branch]),
	format('Next: none~n'),
	format("    -> failed to close the branch~n"),
	format('Unused formulas: ~w~n', [[]]),
	format('---------------------------------------------------------~n'),
	fail.

% If an unbound variable is encountered, mark it as 'continue'.
% The next time we encounter it we see either 'continue' and we skip it,
% or we see 'not(continue)' and we close the branch.
closed_tableau_(Branch, [X|Set]) :-
	var(X),
	format('Branch: ~w~n', [Branch]),
	format('Next: ~w~n', [X]),
	b_getval(marker, Marker),
	NextMarker is Marker + 1,
	b_setval(marker, NextMarker),
	X = continue NextMarker,
	format('    -> a new variable encountered, name it ~w~n', [NextMarker]),
	format('    -> the literal is positive, mark it to be skipped~n'),
	format('Unused formulas: ~w~n', [Set]),
	format('---------------------------------------------------------~n'),
	closed_tableau_([NextMarker|Branch], Set),
	!.

% If we encounter 'not(X)', we set X to stop, because the next time we see it,
% we can safely close the branch.
closed_tableau_(Branch, [non X|Set]) :-
	var(X),
	format('Branch: ~w~n', [Branch]),
	format('Next: ~w~n', [non X]),
	b_getval(marker, Marker),
	NextMarker is Marker + 1,
	b_setval(marker, NextMarker),
	X = stop NextMarker,
	format('    -> a new variable encountered, name it ~w~n', [NextMarker]),
	format('    -> the literal is negative, mark it to close branches~n'),
	format('Unused formulas: ~w~n', [Set]),
	format('---------------------------------------------------------~n'),
	( 
		  (closed_tableau_([non NextMarker|Branch], Set), !) 
		; (!, fail)
	).

% Otherwise jump to the bound variables section.
closed_tableau_(Branch, [X|Set]) :-
	nonvar(X),
	closed_tableau_b(Branch, [X|Set]).

%%% closed_tableau_b(+Formulae)
%
% closed_tableau for bound variables

% If we encounter 'stop', we just close the branch.
closed_tableau_b(Branch, [stop Marker|Set]) :-
	format('Branch: ~w~n', [Branch]),
	format('Next: ~w~n', [stop Marker]),
	format('    -> CLOSE BRANCH ~w~n', [[Marker|Branch]]),
	format('Unused formulas: ~w~n', [[stop Marker|Set]]),
	format('---------------------------------------------------------~n'),
	!.

% non continue ~ stop
closed_tableau_b(Branch, [non continue Marker|Set]) :-
	format('Branch: ~w~n', [Branch]),
	format('Next: ~w~n', [non continue Marker]),
	format('    -> CLOSE BRANCH ~w~n', [[Marker|Branch]]),
	format('Unused formulas: ~w~n', [Set]),
	format('---------------------------------------------------------~n'),
	!.

% If we encounter 'continue', we just skip it, because we have seen it already.
closed_tableau_b(Branch, [continue Marker|Set]) :-
	format('Branch: ~w~n', [Branch]),
	format('Next: ~w~n', [continue Marker]),
	format('    -> skip~n'),
	format('Unused formulas: ~w~n', [Set]),
	format('---------------------------------------------------------~n'),
	closed_tableau_([Marker|Branch], Set),
	!.

% non stop ~ continue
closed_tableau_b(Branch, [non stop Marker|Set]) :-
	format('Branch: ~w~n', [Branch]),
	format('Next: ~w~n', [non stop Marker]),
	format('    -> skip~n'),
	format('Unused formulas: ~w~n', [Set]),
	format('---------------------------------------------------------~n'),
	closed_tableau_([Marker|Branch], Set),
	!.

%% AND rule, just serialize the formulas.
closed_tableau_b(Branch, [Phi & Psi|Set]) :- 
	format('Branch: ~w~n', [Branch]),
	format('Next: ~w~n', [Phi & Psi]),
	format('    -> serialize following:~n'),
	format('        ~w~n', [Phi]),
	format('        ~w~n', [Psi]),
	format('Unused formulas: ~w~n', [Set]),
	format('---------------------------------------------------------~n'),
	closed_tableau_(Branch, [Phi,Psi|Set]),
	!.

%% OR rule, create a new branch.
closed_tableau_b(Branch, [Phi v Psi|Set]) :-
	format('Branch: ~w~n', [Branch]),
	format('Next: ~w~n', [Phi v Psi]),
	format('    -> apply OR rule - create branches for:~n'),
	format('        ~w~n', [Phi]),
	format('        ~w~n', [Psi]),
	format('Unused formulas: ~w~n', [Set]),
	format('---------------------------------------------------------~n'),
	closed_tableau_(Branch, [Phi|Set]),
	closed_tableau_(Branch, [Psi|Set]).
