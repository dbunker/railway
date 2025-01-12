#include "common.lp".
#include "track_type_decoding.lp".
#include "graph/create_directed_graph.lp".

node(N) :- cell(N,_).
goal(ID,(X,Y)) :- end_custom(ID,(X,Y),_).
spawn(ID,U) :- node_start(U,ID).

% --- PATH CANDIDATES --------------------------------------------------------------------------------------------------

% Generate Moves
{move(ID,U,V): output_edge(U,V,_)} <= 1 :- train(ID), output_node(V).
{move(ID,U,V): output_edge(U,V,_)} <= 1 :- train(ID), output_node(U).

% Transitivity of Moves
:- move(ID,U,_), not spawn(ID,U), not move(ID,_,U).
:- move(ID,_,((X,Y),DIR)), not goal(ID,(X,Y)), not move(ID,((X,Y),DIR),_).

% No out of plan moves
:- spawn(ID,U), move(ID,_,U).
:- goal(ID,(X,Y)), move(ID,((X,Y),_),_).

% Enforce Start and End
:- spawn(ID,((X,Y),DIR)), not goal(ID,(X,Y)), not move(ID,((X,Y),DIR),_).
:- goal(ID,(X,Y)), not spawn(ID,((X,Y),_)), not move(ID,_,((X,Y),_)).

% --- ORDER RESOLVE ----------------------------------------------------------------------------------------------------

% Resolve moving into Start & End
resolve(ID1,ID2,U) :- spawn(ID1,U), move(ID2,_,U), ID1!=ID2.
resolve(ID1,ID2,((X,Y),DIR)) :-  goal(ID1,(X,Y)), move(ID2,_,((X,Y),DIR)), ID1!=ID2.

% Resolve to trains moving into the same node
{resolve(ID1,ID2,U); resolve(ID2,ID1,U)} >= 1 :- move(ID1,_,U), move(ID2,_,U), ID1<ID2.

% Prohibit opposite resolutions for same node
:- resolve(ID1,ID2,U), resolve(ID2,ID1,U).

#show resolve/3.
#show move/3.