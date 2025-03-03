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
resolve(ID1,ID2,(X,Y)) :- spawn(ID1,((X,Y),_)), move(ID2,_,((X,Y),_)), ID1!=ID2.
resolve(ID1,ID2,(X,Y)) :- goal(ID1,(X,Y)), move(ID2,_,((X,Y),_)), ID1!=ID2.

% Resolve to trains moving into the same node
{resolve(ID1,ID2,(X,Y)); resolve(ID2,ID1,(X,Y))} >= 1 :- move(ID1,_,((X,Y),_)), move(ID2,_,((X,Y),_)), ID1<ID2.

% Prohibit opposite resolutions for same node
:- resolve(ID1,ID2,(X,Y)), resolve(ID2,ID1,(X,Y)).

% ----------------------------------------------------------------------------------------------------------------------

% PATH VERIFICATION: No conflicting orders on different nodes on same path

before(T,(X1,Y1),(X2,Y2)) :- move(T,((X1,Y1),_),((X2,Y2),_)).
before(T,(X0,Y0),(X2,Y2)) :- move(T,((X0,Y0),_),((X1,Y1),_)), before(T,(X1,Y1),(X2,Y2)).

order_waited(T,(X,Y),T2) :- move(T,_,((X,Y),_)), resolve(T2,T,(X,Y)).
order_waited(T,N,T3) :- order_waited(T,N,T2), resolve(T3,T2,N).

:- order_waited(T1,N1,T2), order_waited(T2,N2,T1). %, before(T1,N2,N1).

% ----------------------------------------------------------------------------------------------------------------------

#edge ((ID,U),(ID,V)) : move(ID,U,V).
#edge ((ID1,V),(ID2,U)) : resolve(ID1,ID2,U), move(IDA,U,V).

% #show order_waited/3.
#show resolve/3.
#show move/3.