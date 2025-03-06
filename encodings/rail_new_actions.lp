#include "track_type_decoding.lp".

% --- [ TRAINS ] -------------------------------------------------------------------------------------------------------

% A train can't be a two positions at the same time
:- at(ID,POS_1,_,T), at(ID,POS_2,_,T), POS_1!=POS_2.

% the only way for a train to change cells is if there is an edge to the other cell with associated start and end directions
:-  at(ID,POS,DIR,T),
    at(ID,POS_AFTER,DIR_AFTER,T+1),
    not edge(POS,DIR,POS_AFTER,DIR_AFTER,_).

% --- [ COLLISIONS ] ---------------------------------------------------------------------------------------------------

% no two trains can exist at the same position and time (train(id, position, time))
% for trains with same position, same time, must be the same trains
:-  at(ID_A,POS,_,T),
    at(ID_B,POS,_,T),
    ID_A!=ID_B.

% trains cannot pass each other over the same edge (regardless of edge direction) (i.e. swap places)
:-  at(ID_A,POS_A,_,T),
    at(ID_B,POS_B,_,T),
    at(ID_A,POS_B,_,T+1),
    at(ID_B,POS_A,_,T+1),
    ID_A!=ID_B.

% --- [ GENERATION ] ---------------------------------------------------------------------------------------------------

action_type(move_forward;move_left;move_right;wait).

% Generate positions
{ action(ID,A,T): action_type(A) } 1 :- time(T), start_custom(ID,_,T_START,_), T>=T_START, end_custom(ID,_,T_END), T<=T_END.

% Action gaps are forbidden
:- action(ID,_,T1), action(ID,_,T3), time(T2), not action(ID,_,T2), T1<T2, T2<T3.

% --- [ START ] --------------------------------------------------------------------------------------------------------

% Detect train spawn
spawn(ID,T) :- action(ID,_,T), not action(ID,_,T-1).

% The first position must be the start position
at(ID,POS_START,DIR_START,T) :- spawn(ID,T), start_custom(ID,POS_START,_,DIR_START).

% --- [ POSITIONS ] ------------------------------------------------------------------------------------------------------

at(ID,POS_AFTER,DIR_AFTER,T+1) :- action(ID,A,T), at(ID,POS,DIR,T), edge(POS,DIR,POS_AFTER,DIR_AFTER,A).

% Actions need to be possible
:- action(ID,A,T), at(ID,POS,DIR,T), not edge(POS,DIR,_,_,A).

% --- [ ARRIVAL ] ------------------------------------------------------------------------------------------------------

% Train Arrival
arrived(ID,T) :- end_custom(ID,POS,T_END), at(ID,POS,_,T), T<=T_END.
:- train(ID), not arrived(ID,_).

% --- [ OPTIMIZATION ] -------------------------------------------------------------------------------------------------

% #minimize{ ID, T : at(ID,_,_,T) }.

#show at/4.
%#show arrived/2.
%#show action/3.
%#show spawn/2.
%#show start_custom/4.
