
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

start(b, (1,0), 1).
end(b, (0,0), 5).

edge((0,0), (0,1), 1).
edge((0,1), (0,2), 1).

edge((0,1), (1,1), 1).

edge((1,0), (1,1), 1).
edge((1,1), (1,2), 1).
edge((1,2), (1,3), 1).

#show start/3.
#show end/3.

#show edge/2.
#show at/2.

#show move/3.

% #show backwards/3.

% reverse edges
edge(A, B, W) :- edge(B, A, W).
edge(A, B) :- edge(B, A, W).

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

% prevent move cycles
path(ID, PREV, POS) :- move(ID, PREV, POS).
path(ID, FARTHER_PREV, POS) :- path(ID, FARTHER_PREV, PREV), path(ID, PREV, POS).
:- path(ID, PREV, POS), path(ID, POS, PREV).

% prevent more than 1 path out
:- move(ID, PREV, POS_A), move(ID, PREV, POS_B), POS_A != POS_B.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prevent collision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

resolve(A,B,U) :- start(A, U, _), move(B,_,U), A!=B.

resolve(A,B,U) :- end(B, U, _), move(A,_,U), A!=B.

{ resolve(A,B,U); resolve(B,A,U) } >= 1 :- move(A,_,U), move(B,_,U), A<B.

:- resolve(A,B,U), resolve(B,A,U).

:- move(A,U,V), move(B,V,U), A<B, not resolve(A,B,V), not resolve(B,A,U).

% #edge ((A,U),(A,V)) : move(A,U,V).
% #edge ((A,V),(B,U)) : resolve(A,B,U), move(A,U,V).

&diff{(A,U)+D}<=(A,V) :- move(A,U,V), edge(U,V,D).
&diff{(A,V)+W}<=(B,U) :- resolve(A,B,U), move(A,U,V), edge(U,V,W).

#show resolve/3.
