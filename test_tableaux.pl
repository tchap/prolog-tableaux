%%% TESTS
%
% If you get no warning saying that a predicate failed,
% then all the test succeeded.

:- consult(tableaux).

% axioms
:- tautology(A => (B => A)).
:- tautology((A => (B => C)).
:- tautology((non B => non A) => (A => B)).

% can be proven to be tautology
:- tautology(non A => A => B).
:- tautology(A => non A => B).
:- tautology(A & non A => B).
:- tautology(non non A => A).
:- tautology(A => non non A).
:- tautology((B => A) => (non A => non B)).
:- tautology(A => non B => non(A => B)).
:- tautology((non A => A) => A).

:- \+ tautology(non(non A => A => B)).
:- \+ tautology(non(A => non A => B)).
:- \+ tautology(non(A & non A => B)).
:- \+ tautology(non(non non A => A)).
:- \+ tautology(non(A => non non A)).
:- \+ tautology(non((B => A) => (non A => non B))).
:- \+ tautology(non(A => non B => non(A => B))).
:- \+ tautology(non((non A => A) => A)).

:- tautology(A <=> A).
:- \+ tautology(A <=> B).

:- \+ satisfiable([(A v B v C) & non A & non B & non C]).
:- satisfiable([(A v B v C v D) & non A & non B & non C]).
:- \+ satisfiable([A v B, B v C, A => B, non B]).
