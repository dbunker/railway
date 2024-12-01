% --- [ INITIAL GRAPH ] ------------------------------------------------------------------------------------------------

initial_node(((X,Y),DIR)) :- cell_custom((X,Y),_), dir(DIR).
initial_edge((POS_IN,DIR_IN),(POS_OUT,DIR_OUT)) :- edge(POS_IN,DIR_IN,POS_OUT,DIR_OUT,A), A!=wait.

% --- [ SWITCHES ] -----------------------------------------------------------------------------------------------------

switch(N) :- initial_node(N), 2{initial_edge(N,_)}.  % more than two outgoing edges = switch

% --- [ SWITCH CONNECTIONS ] -------------------------------------------------------------------------------------------

reachable(SWITCH_1,N,0) :- initial_edge(SWITCH_1,N), switch(SWITCH_1), not switch(N).
connection(SWITCH_1,SWITCH_2,0) :- initial_edge(SWITCH_1,SWITCH_2), switch(SWITCH_1), switch(SWITCH_2).

reachable(SWITCH_1,N2,D+1) :- reachable(SWITCH_1,N1,D), initial_edge(N1,N2), not switch(N2).
connection(SWITCH_1,SWITCH_2,D+1) :- reachable(SWITCH_1,N,D), initial_edge(N,SWITCH_2), switch(SWITCH_2).

% --- [ START AND END POSITIONS ] --------------------------------------------------------------------------------------

node_start(((X,Y),DIR),ID) :- start_custom(ID,(X,Y),_,DIR).
switch(N) :- node_start(N,_).

node_end(((X,Y),DIR),ID) :- end_custom(ID,(X,Y),_), dir(DIR).
switch(N) :- node_end(N,_).

% --- [ OUTPUT GRAPH ] -------------------------------------------------------------------------------------------------

output_node(N) :- switch(N).
output_edge(N1,N2,D) :- connection(N1,N2,D).




%#show node_end/2.
%#show node_start/2.
%#show output_node/1.
%#show output_edge/3.