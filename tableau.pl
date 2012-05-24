%%%
%%% Method of analytic tableaux for propositional logic
%%%

unsatisfiable(Formulae) :- closed_tableau(Formulae).

closed_tableau([X|Set]) :-
	var(X),
	X = continue,
	closed_tableau(Set).

closed_tableau([X|Set]) :-
	\+ var(X),
	closed_tableau_b([X|Set]).

closed_tableau_b([n(X)|Set]) :-
	var(X),
	X = close,
	closed_tableau(Set).

closed_tableau_b([close|_]).
closed_tableau_b([n(continue)|_]).

closed_tableau_b([continue|Set]) :- closed_tableau(Set).

closed_tableau_b([a(Phi,Psi)|Set]) :- closed_tableau([Phi,Psi|Set]).
closed_tableau_b([o(Phi,Psi)|Set]) :-
	closed_tableau([Phi|Set]),
	closed_tableau([Psi|Set]).
