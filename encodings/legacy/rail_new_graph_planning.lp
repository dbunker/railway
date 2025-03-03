#include "common.lp".
#include "track_type_decoding.lp".
#include "graph/create_directed_graph.lp".

% --- [ STEPS ] --------------------------------------------------------------------------------------------------------

step(1..10).

% --- [ TRAIN STEPS ] --------------------------------------------------------------------------------------------------

{graph_at(ID,N,S): output_node(N)}1 :- train(ID), step(S).

% The graph_at positions for the trains can't have holes in continuation
:- graph_at(ID,_,S1), graph_at(ID,_,S3), step(S2), not graph_at(ID,_,S2), S1<S2, S2<S3.

% --- [ START & END ] --------------------------------------------------------------------------------------------------

spawn_time(ID,S) :- graph_at(ID,_,S), not graph_at(ID,_,S-1).
last_time(ID,S) :- graph_at(ID,_,S), not graph_at(ID,_,S+1).
arrived(ID) :- last_time(ID,S), graph_at(ID,((X,Y),_),S), end_custom(ID,(X,Y),_).

:- spawn_time(ID,S), start_custom(ID,(X,Y),_,DIR), not graph_at(ID,((X,Y),DIR),S).
:- last_time(ID,S), end_custom(ID,(X,Y),_), not graph_at(ID,((X,Y),_),S).

% --- [ END CONDITION ] ------------------------------------------------------------------------------------------------

:- train(ID), not arrived(ID).

% --- [ POSITION TRANSITIONS ] -----------------------------------------------------------------------------------------

:- graph_at(ID,N1,S), graph_at(ID,N2,S+1), not output_edge(N1,N2,_).


%#show spawn_time/2.
%#show last_time/2.
%#show graph_at/3.
