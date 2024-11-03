% cell((X, Y), TYPE)
% track at (X, Y) with track type TYPE

% cell((X, Y), VERTICAL, HORIZONTAL, EAST_NORTH, EAST_SOUTH, WEST_NORTH, WEST_SOUTH)
% track at (X, Y) with individual tracks indicated

% TYPE:
% vertical: 32800
% horizontal: 1025
% type 5 double-slip switch west-east, north-south, north-east, west-south: 38505

% start(ID, (X, Y), DEP, DIR)
% train ID starts at (X, Y) with earliest departure time DEP with direction DIR ({n, s, e, w})

% end(ID, (X,Y), ARR)
% train ID ends at (X, Y) at latest arrival time ARR

% train(ID, (X, Y), T, DIR)
% train ID is at (X, Y) at time T going direction DIR

% edge((X_START, Y_START), (X_END, Y_END), DIR_START, DIR_END)
% train at (X_START, Y_START) with starting direction DIR_START can move to (X_END, Y_END) with ending direction DIR_END

% action(train(ID), ACT, T)
% train ID took actions ACT at timestep T
% ACT: move_forward, move_left, move_right, wait

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#show train/4.
#show action/3.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initial and end train positions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% train ID must be at starting (X, Y) going direction DIR at ACTUAL_DEP
train(ID, (X, Y), ACTUAL_DEP, DIR) :- start(ID, (X, Y), _, DIR), actual_start(ID, ACTUAL_DEP).

% train ID must be at ending (X, Y) by actual arrival ACTUAL_ARR
:- not train(ID, (X, Y), ACTUAL_ARR, _), end(ID, (X, Y), _), actual_end(ID, ACTUAL_ARR).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create individual tracks from cells
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convert cells to the form:
% cell((X, Y), VERTICAL, HORIZONTAL, EAST_NORTH, EAST_SOUTH, WEST_NORTH, WEST_SOUTH)

% type 1
cell((X, Y), 1, 0, 0, 0, 0, 0) :- cell((X, Y), 32800).
cell((X, Y), 0, 1, 0, 0, 0, 0) :- cell((X, Y), 1025).

cell((X, Y), 0, 0, 1, 0, 0, 0) :- cell((X, Y), 72).
cell((X, Y), 0, 0, 0, 1, 0, 0) :- cell((X, Y), 16386).
cell((X, Y), 0, 0, 0, 0, 1, 0) :- cell((X, Y), 2064).
cell((X, Y), 0, 0, 0, 0, 0, 1) :- cell((X, Y), 4608).

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

% TODO: What do we do with dead-end track types? Is it okay to just skip them?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create edges from cells
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% it is assumed that being able to entering into a cell implies being able to exit from it
% where the train can go is dictated by its assigned direction entering into the node
% ex. moving north following a track moving east moves into the cell and changes direction east

% each of these is followed by the possibility of using the track to reverse direction

% there is an edge from (X, Y) to (X+1, Y) assuming the train is going direction east
% if the cells are next to eachother and it is a horizontal track (1025)

% TODO: I don't know if these rule bodies really make much sense? I would probably always use (X,Y) in body.

% vertical track north-south
edge((X, Y), (X, Y+1), s, s) :- cell((X, Y+1), 1, _, _, _, _, _).
edge((X, Y), (X, Y-1), n, n) :- cell((X, Y-1), 1, _, _, _, _, _).

% horizontal track west-east
edge((X, Y), (X+1, Y), e, e) :- cell((X+1, Y), _, 1, _, _, _, _).
edge((X, Y), (X-1, Y), w, w) :- cell((X-1, Y), _, 1, _, _, _, _).

% turn east-north
edge((X, Y), (X, Y+1), s, e) :- cell((X, Y+1), _, _, 1, _, _, _).
edge((X, Y), (X-1, Y), w, n) :- cell((X-1, Y), _, _, 1, _, _, _).

% turn east-south
edge((X, Y), (X, Y-1), n, e) :- cell((X, Y-1), _, _, _, 1, _, _).
edge((X, Y), (X-1, Y), w, s) :- cell((X-1, Y), _, _, _, 1, _, _).

% turn west-north
edge((X, Y), (X, Y+1), s, w) :- cell((X, Y+1), _, _, _, _, 1, _).
edge((X, Y), (X+1, Y), e, n) :- cell((X+1, Y), _, _, _, _, 1, _).

% turn west-south
edge((X, Y), (X+1, Y), e, s) :- cell((X+1, Y), _, _, _, _, _, 1).
edge((X, Y), (X, Y-1), n, w) :- cell((X, Y-1), _, _, _, _, _, 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% train movement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialization
time(0..steps).
train(ID) :- start(ID, _, _, _).
dir(n). dir(s). dir(e). dir(w).

% #show actual_start/2.
% #show actual_end/2.
% #show train_exists/2.

% train only exists upon leaving train station and stops existing once arrived
% define single departure time
{ actual_start(ID, ACTUAL_DEP) :
    time(ACTUAL_DEP),

    start(ID, _, DEP, _),
    DEP <= ACTUAL_DEP

} = 1 :- train(ID).

% define single arrival time after departure
{ actual_end(ID, ACTUAL_ARR) :
    time(ACTUAL_ARR),

    end(ID, _, ARR),
    ACTUAL_ARR <= ARR,

    actual_start(ID, ACTUAL_DEP),
    ACTUAL_DEP <= ACTUAL_ARR

} = 1 :- train(ID).

% train exists in between
train_exists(ID, ACTUAL_DEP..ACTUAL_ARR) :-
    actual_start(ID, ACTUAL_DEP),
    actual_end(ID, ACTUAL_ARR).

% train ID must exist at a single time T and (X, Y) and going in a single direction DIR between departure and arrival times
{ train(ID, (X, Y), T, DIR) : cell((X, Y), TRACK), dir(DIR), TRACK != 0 } = 1 :- train_exists(ID, T).

% the only way for a train to change cells is if there is an edge to the other cell with associated start and end directions 
:-  train(ID, POS, T, DIR),
    train(ID, NEXT_POS, T+1, NEXT_DIR),
    not edge(POS, NEXT_POS, DIR, NEXT_DIR),
    (POS, DIR) != (NEXT_POS, NEXT_DIR).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% train movement with other trains
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% no two trains can exist at the same position and time (train(id, position, time))
% for trains with same position, same time, must be the same trains
:-  train(ID_A, POS, T, _), 
    train(ID_B, POS, T, _), 
    ID_A != ID_B.

% trains cannot pass each other over the same edge (regardless of edge direction) (i.e. swap places)
:-  train(ID_A, POS_A, T, _), 
    train(ID_B, POS_B, T, _), 
    train(ID_A, ID_B, T+1, _), 
    train(ID_B, ID_A, T+1, _), 
    edge(POS_A, POS_B, _, _).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% train actions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: I think this is okay but in this case the actions are generated afterwards. Maybe it makes more sense to make
% TODO: a choice for the next action to take and then translate this into movements (less choices).

% go forward
action(train(ID), move_forward, T) :- 
    train(ID, _, T, _), 
    not action(train(ID), wait, T), 
    not action(train(ID), move_left, T), 
    not action(train(ID), move_right, T).

% wait
action(train(ID), wait, T) :- train(ID, POS, T, DIR), train(ID, POS, T+1, DIR).

% go left
action(train(ID), move_left, T) :- train(ID, _, T-1, e), train(ID, _, T, n).
action(train(ID), move_left, T) :- train(ID, _, T-1, n), train(ID, _, T, w).
action(train(ID), move_left, T) :- train(ID, _, T-1, w), train(ID, _, T, s).
action(train(ID), move_left, T) :- train(ID, _, T-1, s), train(ID, _, T, e).

% go right
action(train(ID), move_right, T) :- train(ID, _, T-1, e), train(ID, _, T, s).
action(train(ID), move_right, T) :- train(ID, _, T-1, s), train(ID, _, T, w).
action(train(ID), move_right, T) :- train(ID, _, T-1, w), train(ID, _, T, n).
action(train(ID), move_right, T) :- train(ID, _, T-1, n), train(ID, _, T, e).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% minimize waiting on track (train existing)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% minimize the amount of time any train exists (between start and end)
#minimize { 1, ID, T : train_exists(ID, T) }.
