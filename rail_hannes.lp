% --- [ ENVIRONMENT] ---------------------------------------------------------------------------------------------------

time(0..steps).
dir(n;s;e;w).

% --- [ START ] --------------------------------------------------------------------------------------------------

% Train Start
position(ID, (X, Y), T, DIR) :- start(ID, (X, Y), T, DIR).

% --- [ CELLS ] --------------------------------------------------------------------------------------------------------

% cell((X, Y), VERTICAL, HORIZONTAL, EAST_NORTH, EAST_SOUTH, WEST_NORTH, WEST_SOUTH)

%            V  H  E  E  W  W
%                  N  S  N  S

% type 1
cell((X, Y), 1, 0, 0, 0, 0, 0) :- cell((X, Y), 32800).
cell((X, Y), 0, 1, 0, 0, 0, 0) :- cell((X, Y), 1025).

cell((X, Y), 0, 0, 0, 0, 0, 1) :- cell((X, Y), 4608).
cell((X, Y), 0, 0, 0, 1, 0, 0) :- cell((X, Y), 16386).
cell((X, Y), 0, 0, 1, 0, 0, 0) :- cell((X, Y), 72).
cell((X, Y), 0, 0, 0, 0, 1, 0) :- cell((X, Y), 2064).

% type 2
cell((X, Y), 1, 0, 0, 0, 0, 1) :- cell((X, Y), 37408).
cell((X, Y), 0, 1, 0, 1, 0, 0) :- cell((X, Y), 17411).
cell((X, Y), 1, 0, 1, 0, 0, 0) :- cell((X, Y), 32872).
cell((X, Y), 0, 1, 0, 0, 1, 0) :- cell((X, Y), 3089).

cell((X, Y), 1, 0, 0, 1, 0, 0) :- cell((X, Y), 49186).
cell((X, Y), 0, 1, 1, 0, 0, 0) :- cell((X, Y), 1097).
cell((X, Y), 1, 0, 0, 0, 1, 0) :- cell((X, Y), 34864).
cell((X, Y), 0, 1, 0, 0, 0, 1) :- cell((X, Y), 5633).

% type 3
cell((X, Y), 1, 1, 0, 0, 0, 0) :- cell((X, Y), 33825).

% type 4
cell((X, Y), 1, 1, 0, 0, 0, 1) :- cell((X, Y), 38433).
cell((X, Y), 1, 1, 0, 1, 0, 0) :- cell((X, Y), 50211).
cell((X, Y), 1, 1, 1, 0, 0, 0) :- cell((X, Y), 33897).
cell((X, Y), 1, 1, 0, 0, 1, 0) :- cell((X, Y), 35889).

% type 5
cell((X, Y), 1, 1, 1, 0, 0, 1) :- cell((X, Y), 38505).
cell((X, Y), 1, 1, 0, 1, 1, 0) :- cell((X, Y), 52275).

% type 6
cell((X, Y), 0, 0, 0, 1, 0, 1) :- cell((X, Y), 20994).
cell((X, Y), 0, 0, 1, 1, 0, 0) :- cell((X, Y), 16458).
cell((X, Y), 0, 0, 1, 0, 1, 0) :- cell((X, Y), 2136).
cell((X, Y), 0, 0, 0, 0, 1, 1) :- cell((X, Y), 6672).

% --- [ EDGES ] --------------------------------------------------------------------------------------------------------

% wait is possible everywhere
action_possible(wait, POS, DIR, POS, DIR) :- cell(POS, _, _, _, _, _, _), dir(DIR).

% cell((X, Y), VERTICAL, HORIZONTAL, EAST_NORTH, EAST_SOUTH, WEST_NORTH, WEST_SOUTH)

% vertical track north-south
action_possible(move_forward, (X,Y), s, (X, Y+1), s) :- cell((X, Y), 1, _, _, _, _, _).
action_possible(move_forward, (X,Y), n, (X, Y-1), n) :- cell((X, Y), 1, _, _, _, _, _).

% horizontal track west-east
action_possible(move_forward, (X,Y), e, (X+1, Y), e) :- cell((X, Y), _, 1, _, _, _, _).
action_possible(move_forward, (X,Y), w, (X-1, Y), w) :- cell((X, Y), _, 1, _, _, _, _).

% turn east-north
action_possible(move_right, (X,Y), w, (X, Y-1), n) :- cell((X, Y), _, _, 1, _, _, _).
action_possible(move_left, (X,Y), s, (X+1, Y), e) :- cell((X, Y), _, _, 1, _, _, _).

% turn east-south
action_possible(move_right, (X,Y), n, (X+1, Y), e) :- cell((X, Y), _, _, _, 1, _, _).
action_possible(move_left, (X,Y), w, (X, Y+1), s) :- cell((X, Y), _, _, _, 1, _, _).

% turn west-north
action_possible(move_right, (X,Y), s, (X-1, Y), w) :- cell((X, Y), _, _, _, _, 1, _).
action_possible(move_left, (X,Y), e, (X, Y-1), n) :- cell((X, Y), _, _, _, _, 1, _).

% turn west-south
action_possible(move_right, (X,Y), e, (X, Y+1), s) :- cell((X, Y), _, _, _, _, _, 1).
action_possible(move_left, (X,Y), n, (X-1, Y), w) :- cell((X, Y), _, _, _, _, _, 1).


edge(POS_START, POS_END, DIR_START, DIR_END) :- action_possible(A, POS_START, DIR_START, POS_END, DIR_END), A!=wait.

% --- [ TRAINS ] -------------------------------------------------------------------------------------------------------

% A train can't be a two positions at the same time
:- position(ID, POS_1, T, _), position(ID, POS_2, T, _), POS_1 != POS_2.

% the only way for a train to change cells is if there is an edge to the other cell with associated start and end directions
:-  position(ID, POS, T, DIR),
    position(ID, NEXT_POS, T+1, NEXT_DIR),
    not edge(POS, NEXT_POS, DIR, NEXT_DIR),
    (POS, DIR) != (NEXT_POS, NEXT_DIR).

% --- [ COLLISIONS ] ---------------------------------------------------------------------------------------------------

% no two trains can exist at the same position and time (train(id, position, time))
% for trains with same position, same time, must be the same trains
:-  position(ID_A, POS, T, _),
    position(ID_B, POS, T, _),
    ID_A != ID_B.

% trains cannot pass each other over the same edge (regardless of edge direction) (i.e. swap places)
:-  position(ID_A, POS_A, T, _),
    position(ID_B, POS_B, T, _),
    position(ID_A, POS_B, T+1, _),
    position(ID_B, POS_A, T+1, _),
    edge(POS_A, POS_B, _, _).

% --- [ ACTIONS ] ------------------------------------------------------------------------------------------------------

action_type(wait;move_forward;move_left;move_right).

% Choose one action for every needed timestep
{action(ID, A, T) : action_type(A)}1 :-
    time(T),
    start(ID, _, T_START, _),
    end(ID, _, T_END),
    T >= T_START,
    T < T_END.

% Actions must be possible
:- action(ID, A, T), position(ID, POS, T, DIR), not action_possible(A, POS, DIR, _, _).

% Every timestep before arrival needs an action
:- arrived(ID, T_ARR), start(ID, _, T_START, _), time(T),
   T >= T_START, T < T_ARR, not action(ID, _, T).
% Timesteps after arrival have no action
:- action(ID, _, T), arrived(ID, T_ARR), T >= T_ARR.

% Translate actions into positions
% Once the end point has been reached no new positions are created
position(ID, POS_AFTER, T+1, DIR_AFTER) :- action(ID, A, T),
    position(ID, POS, T, DIR),
    action_possible(A, POS, DIR, POS_AFTER, DIR_AFTER),
    not end(ID, POS, _).

% --- [ ARRIVAL ] ------------------------------------------------------------------------------------------------------

% Train Arrival
arrived(ID, T) :- end(ID, POS, T_END), position(ID, POS, T, _), T <= T_END.
:- train(ID), not arrived(ID, _).

#show position/4.
#show action/3.
#show action_possible/5.
#show arrived/2.
