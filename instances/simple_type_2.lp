% 0 0 0 0
% 0 0 ┌ B
% a ┬─┴ A
% 0 b 0 0

#const steps=4.

cell((0, 0), 0).
cell((1, 0), 0).
cell((2, 0), 0).
cell((3, 0), 0).

cell((0, 1), 0).
cell((1, 1), 0).
cell((2, 1), 16386).
cell((3, 1), 1025).

cell((0, 2), 1025).
cell((1, 2), 17411).
cell((2, 2), 3089).
cell((3, 2), 1025).

cell((0, 3), 0).
cell((1, 3), 32800).
cell((2, 3), 0).
cell((3, 3), 0).

train(train_A).
start(train_A, (0, 2), 0, e).
end(train_A,   (3, 2), 4).

train(train_B).
start(train_B, (1, 3), 0, n).
end(train_B,   (3, 1), 4).
