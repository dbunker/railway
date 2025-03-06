% double slip switch in middle

train(0). start(0,(0,1),0,s). end(0,(1,2),10).
train(1). start(1,(2,1),0,n). end(1,(1,0),10).

% column-wise

cell((0, 0), 0).
cell((1, 0), 1025).
cell((2, 0), 0).

cell((0, 1), 32800).
cell((1, 1), 38505).
cell((2, 1), 32800).

cell((0, 2), 0).
cell((1, 2), 1025).
cell((2, 2), 0).

