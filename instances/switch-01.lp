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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
