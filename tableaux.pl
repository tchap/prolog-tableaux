%%%
%%% Method of analytic tableaux for propositional logic
%%%

%% satisfiable(+Formulae)
%
% Input: a set of formulas in negative normal form
% 	 (at the moment only 'not', 'and', 'or' is allowed, no implication)
%
% Output: succeeds if the set of formulas is satisfiable, fails otherwise
satisfiable(Formulae) :-
	\+ closed_tableau(Formulae).

closed_tableau([X|Set]) :-
	var(X),
	X = continue,
	closed_tableau(Set).

closed_tableau([X|Set]) :-
	nonvar(X),
	closed_tableau_b([X|Set]).

%% CLOSE
closed_tableau_b([stop|_]).
closed_tableau_b([continue|Set]) :-
	closed_tableau(Set).

%% NOT
closed_tableau_b([not(continue)|_]).
closed_tableau_b([not(X)|Set]) :-
	X = stop,
	closed_tableau(Set).

%% AND
closed_tableau_b([and(Phi,Psi)|Set]) :- 
	closed_tableau([Phi,Psi|Set]).

%% OR
closed_tableau_b([or(Phi,Psi)|Set]) :-
	closed_tableau([Phi|Set]),
	closed_tableau([Psi|Set]).
