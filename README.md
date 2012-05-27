prolog-tableaux
===============

Method of analytic tableaux for propositional logic

Example output
==============

?- tautology((X => X) & Y).
Branch: []
Next: _G2485&non _G2485 v non _G2489
    -> apply OR rule - create branches for:
        _G2485&non _G2485
        non _G2489
Unused formulas: []
---------------------------------------------------------
Branch: []
Next: _G2485&non _G2485
    -> serialize following:
        _G2485
        non _G2485
Unused formulas: []
---------------------------------------------------------
Branch: []
Next: _G2485
    -> a new variable encountered, name it 1
    -> the literal is positive, mark it to be skipped
Unused formulas: [non continue 1]
---------------------------------------------------------
Branch: [1]
Next: non continue 1
    -> CLOSE BRANCH [1,1]
Unused formulas: []
---------------------------------------------------------
Branch: []
Next: non _G2489
    -> a new variable encountered, name it 2
    -> the literal is negative, mark it to close branches
Unused formulas: []
---------------------------------------------------------
Branch: [non 2]
Next: none
    -> failed to close the branch
Unused formulas: []
---------------------------------------------------------
false.