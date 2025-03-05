#include "rail_new_graph_planning.lp".

% --- [ TRAIN STEPS ] --------------------------------------------------------------------------------------------------

possible_action(wait;continue).

1{action(ID,A,T): possible_action(A)}1 :- train(ID), time(T).

% Start at time 0 at start position
at(ID,N,0) :- graph_at(ID,N,S), spawn_time(ID,S).

% --- [ Wait action ] --------------------------------------------------------------------------------------------------

at(ID,N,T+1) :- at(ID,N,T), action(ID,wait,T).

% --- [ Continue action ] ----------------------------------------------------------------------------------------------

% No Graph Step
at(ID,N2,T+1) :- at(ID,N1,T), action(ID,continue,T), initial_edge(N1,N2), not graph_at(ID,N1,_).
% Graph Step
at(ID,N2,T+1) :- at(ID,N1,T), action(ID,continue,T), initial_edge(N1,N2), graph_at(ID,N1,S),
                 graph_at(ID,N_NEXT,S+1), reachable_reverse(N2,N_NEXT).

% --- [ STEP COMPLETED ] -----------------------------------------------------------------------------------------------

completed(ID,S) :- at(ID,N,_), graph_at(ID,N,S).

% --- [ GOAL CONDITION ] -----------------------------------------------------------------------------------------------

% :- graph_at(ID,_,S), not completed(ID,S).

% :- not at(ID,((X,Y),_),_), end_custom(ID,(X,Y),_).

sum_completed(SUM) :- SUM=#sum{1,ID: completed(ID,S)}.

#maximize{SUM: sum_completed(SUM)}.

%#show reachable_reverse/2.
#show at/3.
#show completed/2.
%#show action/3.