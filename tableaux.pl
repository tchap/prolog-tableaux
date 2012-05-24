%%%
%%% Method of analytic tableaux for propositional logic
%%%

%% satisfiable(+Formulae)
%
% Input: a set of formulas in the negative normal form
% 	 (at the moment only 'not', 'and', 'or' are allowed, no implication)
%
% Output: succeeds if the set of formulas is satisfiable, fails otherwise
satisfiable(Formulae) :-
	\+ closed_tableau(Formulae).

%% closed_tableau(+Formulae)

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

%% closed_tableau_b(+Formulae)
%
% closed_tableau for bound variables

% If we encounter 'stop', we just close the branch.
closed_tableau_b([stop|_]).

% If we encounter 'continue', we just skip it, because we have seen it already.
closed_tableau_b([continue|Set]) :-
	closed_tableau(Set).

% 'not(continue)' ~ 'stop'
closed_tableau_b([not(continue)|_]).

% If we encounter 'not(X)', we set X to stop, because the next time we see it,
% we can safely close the branch.
closed_tableau_b([not(X)|Set]) :-
	X = stop,
	closed_tableau(Set).

% AND rule, just serialize the formulas.
closed_tableau_b([and(Phi,Psi)|Set]) :- 
	closed_tableau([Phi,Psi|Set]).

% OR rule, create a new branch.
closed_tableau_b([or(Phi,Psi)|Set]) :-
	closed_tableau([Phi|Set]),
	closed_tableau([Psi|Set]).
