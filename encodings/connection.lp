#include "common.lp".
#include "track_type_decoding.lp".
#include "graph/create_directed_graph.lp".

{connection(N1,N2,N,M,A)} <= 1 :- move(_,N1,N2), edge(N,_,M,_,A), A!=wait.

% Require Start & End connections
:- move(_,(N1,DIR1),(N2,DIR2)), not connection((N1,DIR1),(N2,DIR2),N1,_,_).
:- move(_,(N1,DIR1),(N2,DIR2)), not connection((N1,DIR1),(N2,DIR2),_,N2,_).

% No invalid moves
:- connection((N1,DIR1),(N2,DIR2),_,N1,_).
:- connection((N1,DIR1),(N2,DIR2),N2,_,_).

% Reachable
connection_reachable(N,M) :- connection(N1,N2,N,M,_).
connection_reachable(N,O) :- connection_reachable(N,M), connection(N1,N2,M,O,_).

% DONT ALLOW UNREACHABLE CONNECTIONS
:- connection((N1,_),_,N,_,_), not connection_reachable(N1,N), N1!=N.
:- connection((N1,_),_,_,N,_), not connection_reachable(N1,N), N1!=N.
:- connection(_,(N2,_),_,N,_), not connection_reachable(N,N2), N2!=N.
:- connection(_,(N2,_),N,_,_), not connection_reachable(N,N2), N2!=N.

% All moves habe to be reachable
:- move(_,(N1,_),(N2,_)), not connection_reachable(N1,N2).

% #show connection_reachable/2.
% #show connection/5.