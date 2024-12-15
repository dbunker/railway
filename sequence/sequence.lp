
%                  (a,e,4) (1,3)
%                            |
%  (a,s,0) (0,2)           (1,2)
%            |               |
%          (0,1) --------- (1,1)
%            |               |
%  (b,e,5) (0,0)   (b,s,0) (1,0)

% at(a,(0,2)), at(a,(0,1)), at(a,(1,1)), at(a,(1,2)), at(a,(1,3)), at(a,(1,3))
% at(b,(1,0)), at(b,(1,0)), at(b,(1,0)), at(b,(1,1)), at(b,(0,1)), at(b,(0,0))

start(a, (0,2), 0).
end(a, (1,3), 4).

% start(b, (1,0), 1).
% end(b, (0,2), 5).

edge((0,0), (0,1)).
edge((0,1), (0,2)).

edge((0,2), (1,2)).

edge((0,1), (1,1)).

edge((1,0), (1,1)).
edge((1,1), (1,2)).
edge((1,2), (1,3)).

#show start/3.
#show end/3.

#show edge/2.
#show at/2.

#show move/3.

% #show backwards/3.

% reverse edges
edge(A, B) :- edge(B, A).

% nodes
node(POS) :- edge(POS, _). 

% start position
at(ID, POS) :- start(ID, POS, _).

% transition by edge
{ move(ID, PREV, POS) : edge(POS, PREV) } :- at(ID, PREV).
at(ID, POS) :- move(ID, _, POS).

% must end at end 
:- end(ID, POS, _), not at(ID, POS).

% prevent reverse back 
:- move(ID, PREV, POS), move(ID, POS, PREV).

% backwards
backwards(ID, POS, PREV) :- end(ID, POS, _), move(ID, PREV, POS).

backwards(ID, POS, PREV) :- backwards(ID, _, POS), move(ID, PREV, POS).

% can't have a move forwards without one back
:- move(ID, PREV, POS), not backwards(ID, POS, PREV).
