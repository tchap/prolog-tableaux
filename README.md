prolog-tableaux
===============

For my school project I decided to implement the method of analytic tableaux for determining the satisfiability of finite sets of a propositional logic formulas in Prolog. You can read more about this method on [.Wikipedia](http://en.wikipedia.org/wiki/Method_of_analytic_tableaux).

Algorithm
---------

### Input Format

I defined a few custom operators so that it's more natural to write formulas to be used as the input for all useful predicates.

* `op(200, fy, non)`
* `op(210, yfx, &)`
* `op(220, yfx, v)`
* `op(230, xfy, =>)`
* `op(240, xfx, <=>)`

This means that priorities and asociativity work as expected, e.g. `non X => Y & Z` is the same as `non(X) => (Y & Z)`.As you may have noticed, I use regular Prolog variables to represent propositional variables. This has a lot to do with how the algorithm is implemented (you will see later).

### Useful Predicates

* `satisfiable(+ListOfFormulas)` accepts a list of formulas defined using the operators above and succeeds if the set is satisfiable, fails otherwise;
* `tautology(+Formula)` check whether the formula is tautology, fails otherwise

Then there are a few more predicates like `nnt(+Formula, -NNTFormula)`, which converts the formulate into the NNT and also converts implications and equivalences, and `closed_tableau(+NNTFormulas)`, which tries to find a closed tableau for the set of formulas it receives. You don't need to use those predicates directly.

All predicates fail when you expect them to do so, and they return rather odd bindings otherwise. That is considered a success, although it does not make any apparent sense.

### Implementation

As a user you are supposed to use `satisfiable(+ListOfFormulas)` or `tautology(+SingleFormula)`. They both, however, do quite the same thing to achive their respective goals:

1. convert all the input formulas into the Negative Normal Form and get rid of implications and equivalences;
2. run `closed_tableau(+ListOfFormulas)`, which succeeds if and only if it manages to find a closed tableau for the set of input formulas;
3. process the result

The main point of the whole process is to find a closed tableau, but how do we do that? We use those Prolog variables representing our propositional variables to insert marks into the formulas in a clever way. This is easy to do because of the way how Prolog treats variables. They are nothing more than references, so once you bind a value to a variable, the variable is "substituted" everywhere in the formula, because it points to the same place.
Now if you remember how branches are closed in this method of analytic tableaux, the only thing we need to do once we encounter a literal is to check if we haven't seen its negation. And this is where the marks come to place. This is how they are inserted (= bound to variables) and used:

* if you encounter an unbound variable which is a positive literal, generate a unique ID and bind the variable to "continue <ID>";
* if you encounter an unbound variable which is a negative literal, generate a unique ID and bind the variable to "stop <ID>"
* if you encounter "continue <ID>", just skip it, because you know that you have already seen the same positive literal before;
* same goes for "non stop <ID>", it means that we have just encountered a negative literal we have seen before;
* if you encounter "stop <ID>", you close the branch, because at this point you know that you have already seen both positive and negative form of a literal, so the rule for closing branches is met;
* same goes for "non continue <ID>", it means that we have just encountered the negative form of a literal we have seen before

This is more or less how it works, but I strongly recommend to see the code itself, it's easy to understand and quite self-explanatory.
