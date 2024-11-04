% 0 0 0 0
% 0 0 ┌ B
% a ┬─┴ A
% 0 b 0 0

% SOLUTION
% position(train_A,(0,2),0,e)
% action(train_A,wait,0)
% position(train_A,(0,2),1,e)
% action(train_A,move_forward,1)
% position(train_A,(1,2),2,e)
% action(train_A,move_forward,2)
% position(train_A,(2,2),3,e)
% action(train_A,move_forward,3)
% position(train_A,(3,2),4,e)
% arrived(train_A,4)
%
%
% position(train_B,(1,3),0,n)
% action(train_B,move_forward,0)
% position(train_B,(1,2),1,n)
% action(train_B,move_right,1)
% position(train_B,(2,2),2,e)
% action(train_B,move_left,2)
% position(train_B,(2,1),3,n)
% action(train_B,move_right,3)
% position(train_B,(3,1),4,e)
% arrived(train_B,4)


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
