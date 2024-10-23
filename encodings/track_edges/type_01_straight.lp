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