%%%
%%% Method of analytic tableaux for propositional logic
%%%

satisfiable(Formulae) :-
	\+ closed_tableau(Formulae).

closed_tableau([X|Set]) :-
	var(X),
	X = continue,
	closed_tableau(Set),
	!.

closed_tableau([X|Set]) :-
	\+ var(X),
	closed_tableau_b([X|Set]),
	!.

%% CLOSE
closed_tableau_b([stop|_]).
closed_tableau_b([continue|Set]) :-
	closed_tableau(Set).

%% NOT
closed_tableau_b([n(continue)|_]).
closed_tableau_b([n(X)|Set]) :-
	X = stop,
	closed_tableau(Set).

%% AND
closed_tableau_b([a(Phi,Psi)|Set]) :- 
	closed_tableau([Phi,Psi|Set]).

%% OR
closed_tableau_b([o(Phi,Psi)|Set]) :-
	closed_tableau([Phi|Set]),
	closed_tableau([Psi|Set]).
