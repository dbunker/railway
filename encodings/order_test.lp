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
:- move(ID,_,((X,Y),DIR)), not   goal(ID,(X,Y)), not move(ID,((X,Y),DIR),_).

% No out of plan moves
:- spawn(ID,U), move(ID,_,U).
:-   goal(ID,(X,Y)), move(ID,((X,Y),_),_).

% Enforce Start and End
:- spawn(ID,((X,Y),DIR)),   not goal(ID,(X,Y)), not move(ID,((X,Y),DIR),_).
:-   goal(ID,(X,Y)), not spawn(ID,((X,Y),_)), not move(ID,_,((X,Y),_)).

% ----------------------------------------------------------------------------------------------------------------------

#show move/3.