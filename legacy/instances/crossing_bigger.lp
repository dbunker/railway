% double slip switch in middle

train(0). start(0,(0,2),0,s). end(0,(2,4),10).
train(1). start(1,(4,2),0,n). end(1,(2,0),10).

% column-wise

cell((0, 0), 0).
cell((1, 0), 0).
cell((2, 0), 1025).
cell((3, 0), 0).
cell((4, 0), 0).

cell((0, 1), 0).
cell((1, 1), 0).
cell((2, 1), 1025).
cell((3, 1), 0).
cell((4, 1), 0).

cell((0, 2), 32800).
cell((1, 2), 32800).
cell((2, 2), 38505).
cell((3, 2), 32800).
cell((4, 2), 32800).

cell((0, 3), 0).
cell((1, 3), 0).
cell((2, 3), 1025).
cell((3, 3), 0).
cell((4, 3), 0).

cell((0, 4), 0).
cell((1, 4), 0).
cell((2, 4), 1025).
cell((3, 4), 0).
cell((4, 4), 0).

