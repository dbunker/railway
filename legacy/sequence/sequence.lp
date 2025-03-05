
%                  (a,e,4) (1,3)
%                            |
%  (a,s,0) (0,2)           (1,2)
%            |               |
%          (0,1) --------- (1,1)
%            |               |
%  (b,e,5) (0,0)   (b,s,0) (1,0)

% at(a,(0,2)), at(a,(0,1)), at(a,(1,1)), at(a,(1,2)), at(a,(1,3)), at(a,(1,3))
% at(b,(1,0)), at(b,(1,0)), at(b,(1,0)), at(b,(1,1)), at(b,(0,1)), at(b,(0,0))

% simplify to remove time:
% all start times are 0, add edge from off track with number units to travel (weight) of earliest departure
% all end times are <largest endtime>, add edge to off track with units to travel (weight) <largest endtime> - latest arrival

#const max_run = 6.

start(a, (0,2), 0).
end(a, (1,3), max_run).

start(b, (1,0), 0).
end(b, (0,0), max_run).

edge((0,0), (0,1), 1).
edge((0,1), (0,2), 1).

edge((0,1), (1,1), 1).

edge((1,0), (1,1), 1).
edge((1,1), (1,2), 1).
edge((1,2), (1,3), 1).

#show start/3.
#show end/3.

% #show edge/2.
% #show at/2.

% #show move/3.

% #show backwards/3.

% reverse edges
edge(A, B, W) :- edge(B, A, W).
edge(A, B) :- edge(B, A, W).

% nodes
node(POS) :- edge(POS, _).

% start position
at(ID, POS) :- start(ID, POS, _).

% transition by edge
{ move(ID, PREV, POS) : edge(POS, PREV) } :- at(ID, PREV).
at(ID, POS) :- move(ID, _, POS).

% must end at end
:- end(ID, POS, _), not at(ID, POS).

% prevent reverse back
:- move(ID, PREV, POS), move(ID, POS, PREV).

% backwards
backwards(ID, POS, PREV) :- end(ID, POS, _), move(ID, PREV, POS).

backwards(ID, POS, PREV) :- backwards(ID, _, POS), move(ID, PREV, POS).

% can't have a move forwards without one back
:- move(ID, PREV, POS), not backwards(ID, POS, PREV).

% prevent move cycles
path(ID, PREV, POS) :- move(ID, PREV, POS).
path(ID, FARTHER_PREV, POS) :- path(ID, FARTHER_PREV, PREV), path(ID, PREV, POS).
:- path(ID, PREV, POS), path(ID, POS, PREV).

% prevent more than 1 path out
:- move(ID, PREV, POS_A), move(ID, PREV, POS_B), POS_A != POS_B.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prevent deadlock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% move train A before train B at start location U if B is expected to move to U
resolve(A, B, U) :- start(A, U, _), move(B, _, U), A != B.

% move train A before train B at end location U if A is expected to move to U
resolve(A, B, U) :- end(B, U, _), move(A, _, U), A != B.

% if both train A and B move to location U, one must go before the other
{ resolve(A, B, U); resolve(B, A, U) } >= 1 :- move(A, _, U), move(B, _, U), A < B.

% both going first not possible
:- resolve(A, B, U), resolve(B, A, U).

% start positions
move_together(A, A_POS, B, B_POS) :-
    start(A, A_POS, _), start(B, B_POS, _),
    A < B,
    A_POS != B_POS.

% move A
{ move_together(A, A_NEXT, B, B_POS) } :-
    move_together(A, A_POS, B, B_POS),
    move(A, A_POS, A_NEXT),
    A < B,
    A_POS != B_POS.

% move B
{ move_together(A, A_POS, B, B_NEXT) } :-
    move_together(A, A_POS, B, B_POS),
    move(B, B_POS, B_NEXT),
    A < B,
    A_POS != B_POS.

% move both
{ move_together(A, A_NEXT, B, B_NEXT) } :-
    move_together(A, A_POS, B, B_POS),
    move(A, A_POS, A_NEXT),
    move(B, B_POS, B_NEXT),
    A < B,
    A_POS != B_POS.

% prevent collision
:- move_together(A, A_NEXT, B, B_NEXT), move_together(A, B_NEXT, B, A_NEXT).

% A must go before B (resolve) if both trains use same position and are on opposite sides (by move_together)
:- not resolve(A, B, POS),
    move(A, A_PREV, POS),
    move(B, B_PREV, POS),
    move_together(A, A_PREV, B, B_PREV),
    A < B.

% must end in correct position
:- end(A, A_POS, _), end(B, B_POS, _), A < B, not move_together(A, A_POS, B, B_POS).

% complete within max iterations
:- { move_together(A, A_NEXT, B, B_NEXT) } > max_run.

#show move_together/4.

% remove cycles
#edge ((A,U), (A,V)) : move(A,U,V).
#edge ((A,V), (B,U)) : resolve(A,B,U), move(A,U,V).

#show move/3.

#show resolve/3.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prevent collision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% at(ID, POS, T) :- start(ID, POS, T).

% { move(ID, PREV, POS, T); still(ID, T) } = 1 :- move(ID, PREV, POS), at(ID, PREV, T), end(ID, _, END_T), T < END_T.
% at(ID, POS, T+W) :- move(ID, PREV, POS, T), edge(PREV, POS, W).
% at(ID, POS, T+1) :- at(ID, POS, T), still(ID, T).

% :- end(ID, POS, T), not at(ID, POS, T).

% % prevent trains being at same vertex
% :- at(ID_A, POS, T), at(ID_B, POS, T), ID_A != ID_B.

% % prevent movement in opposite directions while in use
% :- move(ID_A, PREV, POS, T_A), move(ID_B, POS, PREV, T_B), edge(PREV, POS, W), T_A > T_B, T_A < T_B + W.

% #show at/3.
% #show move/4.
