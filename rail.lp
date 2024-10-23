
% cell((X, Y), TYPE)            at (X, Y) with track type TYPE

% TYPE:
% vertical: 32800
% horizontal: 1025
% diamond cross: 33825

% start(ID, (X, Y), DEP, DIR)   train ID starts at (X, Y) with earliest departure time DEP with direction DIR ({n, s, e, w})

% end(ID, (X,Y), ARR)           train ID ends at (X, Y) at latest arrival time ARR

% train(ID, (X, Y), T, DIR)     train ID is at (X, Y) at time T going direction DIR

% edge((X_START, Y_START), (X_END, Y_END), DIR_START, DIR_END)
% train at (X_START, Y_START) with starting direction DIR_START can move to (X_END, Y_END) with ending direction DIR_END

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 0 | 0 
% - + -
% 0 | 0

% 0 B 0 
% A + -
% 0 | 0

#const steps=4.

cell((0, 1), 1025).
cell((2, 1), 1025).

cell((1, 0), 32800).
cell((1, 2), 32800).

cell((1, 1), 33825).

start(train_A, (0, 1), 0, e).
end(train_A, (2, 1), 2).

start(train_B, (1, 0), 1, s).
end(train_B, (1, 2), 3).

#show train/4.

% #show edge/4.

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

% there is an edge from (X, Y) to (X+1, Y) assuming the train is going direction east
% if the cells are next to eachother and it is a horrizontal track (1025)
edge((X, Y), (X+1, Y), e, e) :- cell((X, Y), _), cell((X+1, Y), 1025).

% horizontal track west
edge((X, Y), (X-1, Y), w, w) :- cell((X, Y), _), cell((X-1, Y), 1025).

% vertical track south
edge((X, Y), (X, Y+1), s, s) :- cell((X, Y), _), cell((X, Y+1), 32800).

% vertical track north
edge((X, Y), (X, Y-1), n, n) :- cell((X, Y), _), cell((X, Y-1), 32800).

% diamond cross, west-east north-south
edge((X, Y), (X+1, Y), e, e) :- cell((X, Y), _), cell((X+1, Y), 33825).
edge((X, Y), (X-1, Y), w, w) :- cell((X, Y), _), cell((X-1, Y), 33825).
edge((X, Y), (X, Y+1), s, s) :- cell((X, Y), _), cell((X, Y+1), 33825).
edge((X, Y), (X, Y-1), n, n) :- cell((X, Y), _), cell((X, Y-1), 33825).

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
