%#include "common.lp".
%#include "track_type_decoding.lp".
%#include "graph/create_directed_graph.lp".

% --- FORWARD CONNECTIONS

flatland_edge((N,DIR_N),(M,DIR_M),A) :- edge(N,DIR_N,M,DIR_M,A), A!=wait.

reach(N,M) :- switch(N), flatland_edge(N,M,_).
con(N,M) :- switch(N), flatland_edge(N,M,_), switch(M).

reach(N,O) :- reach(N,M), flatland_edge(M,O,_), not switch(M), not switch(O).
con(N,O) :- reach(N,M), flatland_edge(M,O,_), not switch(M), switch(O).

% --- BACKWARD CONNECTIONS

back((N,M),O,M) :- con(N,M), flatland_edge(O,M,_), reach(N,O).
back((N,M),X,Y) :- back((N,M),Y,Z), Y!=N, flatland_edge(X,Y,_), reach(N,X).
back((N,M),N,Y) :- back((N,M),Y,Z), Y!=N, flatland_edge(N,Y,_).
% Base case where two switches are connected without any nodes in between
back((N,M),N,M) :- con(N,M), flatland_edge(N,M,_), switch(N), switch(M).

% #show connection_reachable/2.
%#show switch/1.
%#show flatland_edge/3.
%#show reach/2.
%#show con/2.
#show back/3.
%#show reach/2.