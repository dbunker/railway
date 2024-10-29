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