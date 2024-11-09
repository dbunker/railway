% --- [ ENVIRONMENT] ---------------------------------------------------------------------------------------------------

time(0..T) :- end(_,_,T).

dir(0..3).
dir_conversion(n,0). dir_conversion(e,1). dir_conversion(s,2). dir_conversion(w,3).

diff(0,( 0,-1)).
diff(1,( 1, 0)).
diff(2,( 0, 1)).
diff(3,(-1, 0)).



%start_custom(ID,POS,T_START,DIR_NEW) :- start(ID,POS,T_START,DIR), dir_conversion(DIR,DIR_NEW).

cell_custom((Y,X),TYPE) :- cell((X,Y),TYPE).
start_custom(ID,(Y,X),T_START,DIR_NEW) :- start(ID,(X,Y),T_START,DIR), dir_conversion(DIR,DIR_NEW).
end_custom(ID,(Y,X),T_END) :- end(ID,(X,Y),T_END).