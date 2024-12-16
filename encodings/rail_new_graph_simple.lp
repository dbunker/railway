#include "common.lp".
#include "track_type_decoding.lp".
#include "graph/create_directed_graph.lp".

% --- [ STEPS ] --------------------------------------------------------------------------------------------------------

step(1..10).

% --- [ GENERATE POSITIONS ] -------------------------------------------------------------------------------------------

{at(ID,N,S)}1 :- train(ID), output_node(N), step(S).

% only one at at a step (per train)
:- at(ID,N1,S), at(ID,N2,S), N1>N2.
% continuous ats
:- at(ID,_,S1), at(ID,_,S3), step(S2), S1<S2, S2<S3, not at(ID,_,S2).

% only allow edge transitions
:- at(ID,N1,S), at(ID,N2,S+1), N1!=N2, not output_edge(N1,N2,_).

% --- [ START ] --------------------------------------------------------------------------------------------------------

spawn_step(ID,S) :- at(ID,_,S), not at(ID,_,S-1).
% train has to start at start position
:- spawn_step(ID,S), node_start(N,ID), not at(ID,N,S).

% --- [ ARRIVE ] -------------------------------------------------------------------------------------------------------

arrive_step(ID,S) :- at(ID,_,S), not at(ID,_,S+1).


:- node_end(N,ID), at(ID,N,S), not arrive_step(ID,S).
% train has to arrive at end position
:- node_end(((X,Y),_),ID), not at(ID,((X,Y),_),_).

#show spawn_step/2.
#show at/3.