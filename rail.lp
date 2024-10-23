% cell((X, Y), TYPE)
% track at (X, Y) with track type TYPE

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% double slip switch in middle
% 0 | 0 
% - + -
% 0 | 0

% train A to bottom middle
% train B to right middle

% 0  B  0 
% A  +  BE
% 0  AE 0

% expected to have 4 stable models:
% A goes first doesn't reverse
% A goes first and reverses
% B goes first doesn't reverse
% B goes first and reverses

#const steps=3.

cell((0, 1), 1025).
cell((2, 1), 1025).

cell((1, 0), 32800).
cell((1, 2), 32800).

cell((1, 1), 38505).

start(train_A, (0, 1), 0, e).
end(train_A, (1, 2), 3).

start(train_B, (1, 0), 0, s).
end(train_B, (2, 1), 3).

#show train/4.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initial and end train positions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% train ID must be at starting (X, Y) going direction DIR at earliest departure T
train(ID, (X, Y), T, DIR) :- start(ID, (X, Y), T, DIR).

% train ID must be at ending (X, Y) by latest departure T
:- not train(ID, (X, Y), T, _), end(ID, (X, Y), T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create edges from cells
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% it is assumed that being able to exit out of a cell implies entering into it
% where the train can go is dictated by it's assigned direction entering into the node
% ex. moving north folowing a track moving east moves into the cell and changes direction east 

% each of these is followed by the possibility of using the track to reverse direction

% there is an edge from (X, Y) to (X+1, Y) assuming the train is going direction east
% if the cells are next to eachother and it is a horrizontal track (1025)

% horizontal track west-east
edge((X, Y), (X+1, Y), e, e) :- cell((X, Y), _), cell((X+1, Y), 1025).
edge((X, Y), (X-1, Y), w, w) :- cell((X, Y), _), cell((X-1, Y), 1025).

% reverse
edge((X, Y), (X, Y), e, w) :- cell((X, Y), 1025).
edge((X, Y), (X, Y), w, e) :- cell((X, Y), 1025).

% vertical track north-south
edge((X, Y), (X, Y+1), s, s) :- cell((X, Y), _), cell((X, Y+1), 32800).
edge((X, Y), (X, Y-1), n, n) :- cell((X, Y), _), cell((X, Y-1), 32800).

% reverse
edge((X, Y), (X, Y), s, n) :- cell((X, Y), 32800).
edge((X, Y), (X, Y), n, s) :- cell((X, Y), 32800).

% type-5 double-slip switch, west-east, north-south, north-east, west-south
edge((X, Y), (X+1, Y), e, e) :- cell((X, Y), _), cell((X+1, Y), 38505).
edge((X, Y), (X-1, Y), w, w) :- cell((X, Y), _), cell((X-1, Y), 38505).

edge((X, Y), (X, Y+1), s, s) :- cell((X, Y), _), cell((X, Y+1), 38505).
edge((X, Y), (X, Y-1), n, n) :- cell((X, Y), _), cell((X, Y-1), 38505).

edge((X, Y), (X, Y+1), s, e) :- cell((X, Y), _), cell((X, Y+1), 38505).
edge((X, Y), (X-1, Y), w, n) :- cell((X, Y), _), cell((X-1, Y), 38505).

edge((X, Y), (X+1, Y), e, s) :- cell((X, Y), _), cell((X+1, Y), 38505).
edge((X, Y), (X, Y-1), n, w) :- cell((X, Y), _), cell((X, Y-1), 38505).

% reverse
edge((X, Y), (X, Y), e, w) :- cell((X, Y), 38505).
edge((X, Y), (X, Y), w, e) :- cell((X, Y), 38505).

edge((X, Y), (X, Y), s, n) :- cell((X, Y), 38505).
edge((X, Y), (X, Y), n, s) :- cell((X, Y), 38505).

edge((X, Y), (X, Y), e, n) :- cell((X, Y), 38505).
edge((X, Y), (X, Y), n, e) :- cell((X, Y), 38505).

edge((X, Y), (X, Y), w, s) :- cell((X, Y), 38505).
edge((X, Y), (X, Y), s, w) :- cell((X, Y), 38505).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% train movement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialization
time(0..steps).
train(ID) :- start(ID, _, _, _).
dir(n). dir(s). dir(e). dir(w).

% train ID must exist at a single time T and (X, Y) and going in a single direction DIR
{ train(ID, (X, Y), T, DIR) : cell((X, Y), _), dir(DIR) } = 1 :- time(T), train(ID).

% the only way for a train to change cells is if there is an edge to the other cell with associated start and end directions 
:- train(ID, POS, T, DIR), train(ID, NEXT_POS, T+1, NEXT_DIR), not edge(POS, NEXT_POS, DIR, NEXT_DIR), (POS, DIR) != (NEXT_POS, NEXT_DIR).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% train movement with other trains
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% no two trains can exist at the same position and time (train(id, position, time))
% for trains with same position, same time, must be the same trains
:- train(ID_A, POS, T, _), train(ID_B, POS, T, _), ID_A != ID_B.

% trains cannot pass each other over the same edge (regardless of edge direction) (i.e. swap places)
:- train(ID_A, POS_A, T, _), train(ID_B, POS_B, T, _), train(ID_A, ID_B, T+1, _), train(ID_B, ID_A, T+1, _), edge(POS_A, POS_B, _, _).
