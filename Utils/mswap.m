function [A,B] = mswap(A,B)
% A B has the same type
temp = A;
A = B;
B = temp;
