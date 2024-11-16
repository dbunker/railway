
% double slip switch in middle
% Γ  -  0  -  ⅂
% |  0  0  0  |
% L  -  -  -  ⅃
% L  -  -  0  0

% train A around

% Γ  A  0  AE ⅂
% |  0  0  0  |
% L  -  -  B  ⅃
% L  -  BE 0  0

cell((0, 0), 16386).
cell((1, 0), 1025).
cell((2, 0), 0).
cell((3, 0), 1025).
cell((4, 0), 4608).

cell((0, 1), 32800).
cell((1, 1), 0).
cell((2, 1), 0).
cell((3, 1), 0).
cell((4, 1), 32800).

cell((0, 2), 16458).
cell((1, 2), 1025).
cell((2, 2), 1025).
cell((3, 2), 1025).
cell((4, 2), 2064).

cell((0, 2), 16458).
cell((1, 2), 1025).
cell((2, 2), 1025).
cell((3, 2), 1025).
cell((4, 2), 2064).

start(train_A, (1, 0), 0, w).
end(train_A, (3, 0), 11).
