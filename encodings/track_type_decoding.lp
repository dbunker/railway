% --- [ TRACK TYPES] ---------------------------------------------------------------------------------------------------

track_type(TYPE) :- cell_custom(_, TYPE).

% --- [ BINARY TRACK REPRESENTATION ] ----------------------------------------------------------------------------------

bits((NN,NE,NS,NW),(EN,EE,ES,EW),(SN,SE,SS,SW),(WN,WE,WS,WW),T) :- track_type(T),
                                                                   WW=(T/(2**0))\2, WS=(T/(2**1))\2, WE=(T/(2**2))\2, WN=(T/(2**3))\2,
                                                                   SW=(T/(2**4))\2, SS=(T/(2**5))\2, SE=(T/(2**6))\2, SN=(T/(2**7))\2,
                                                                   EW=(T/(2**8))\2, ES=(T/(2**9))\2, EE=(T/(2**10))\2, EN=(T/(2**11))\2,
                                                                   NW=(T/(2**12))\2, NS=(T/(2**13))\2, NE=(T/(2**14))\2, NN=(T/(2**15))\2.

% --- [ TRANSITIONS ] --------------------------------------------------------------------------------------------------

%           │ ─  └  ┌  ┘  ┐
transitions(V,H,RT,RB,LT,LB,T) :- bits((NN,NE,NS,NW),(EN,EE,ES,EW),(SN,SE,SS,SW),(WN,WE,WS,WW),T),
                                  V=(NN+SS),
                                  H=(WW+EE),
                                  RT=(WN+SE),
                                  RB=(WS+NE),
                                  LT=(EN+SW),
                                  LB=(ES+NW).

% --- [ POSSIBLE ACTIONS ] ----------------------------------------

action_possible(T,DIR,wait) :- track_type(T), dir(DIR).

action_possible(T,0,move_forward) :- transitions(X,_,_,_,_,_,T), X>0.
action_possible(T,2,move_forward) :- transitions(X,_,_,_,_,_,T), X>0.

action_possible(T,1,move_forward) :- transitions(_,X,_,_,_,_,T), X>0.
action_possible(T,3,move_forward) :- transitions(_,X,_,_,_,_,T), X>0.

action_possible(T,2,move_left   ) :- transitions(_,_,X,_,_,_,T), X>0.
action_possible(T,3,move_right  ) :- transitions(_,_,X,_,_,_,T), X>0.

action_possible(T,3,move_left   ) :- transitions(_,_,_,X,_,_,T), X>0.
action_possible(T,0,move_right  ) :- transitions(_,_,_,X,_,_,T), X>0.

action_possible(T,1,move_left   ) :- transitions(_,_,_,_,X,_,T), X>0.
action_possible(T,2,move_right  ) :- transitions(_,_,_,_,X,_,T), X>0.

action_possible(T,0,move_left   ) :- transitions(_,_,_,_,_,X,T), X>0.
action_possible(T,1,move_right  ) :- transitions(_,_,_,_,_,X,T), X>0.

% --- [ ACTION PROPERTIES ] --------------------------------------------------------------------------------------------

action_direction_change(move_left,   -1).
action_direction_change(move_forward, 0).
action_direction_change(move_right,   1).

% --- [ EDGES ] --------------------------------------------------------------------------------------------------------

edge((X,Y),DIR,(X+DX,Y+DY),DIR_AFTER,A) :- cell_custom((X,Y),T), cell_custom((X+DX,Y+DY),_),
                                           action_possible(T,DIR,A), A!=wait,
                                           action_direction_change(A,DIR_CHANGE), dir(DIR),
                                           DIR_AFTER=(DIR+DIR_CHANGE)\4, diff(DIR_AFTER,(DX,DY)).

edge((X,Y),DIR,(X,Y),DIR,wait) :- edge((X,Y),DIR,_,_,_).

%#show edge/5.
%#show action_possible/3.
%#show transitions/7.
