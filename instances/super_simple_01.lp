% 0 0 0
% a - A
% 0 0 0

cell((0, 0), 0).
cell((0, 1), 0).
cell((0, 2), 0).

cell((1, 0), 1025).
cell((1, 1), 1025).
cell((1, 2), 1025).

cell((2, 0), 0).
cell((2, 1), 0).
cell((2, 2), 0).

train(train_A).
start(train_A, (1, 0), 1, e).
end(train_A,   (1, 2), 4).
