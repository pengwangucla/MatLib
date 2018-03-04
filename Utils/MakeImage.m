function [ Image ] = MakeImage(color,Isize)
%MAKEIMAGE Summary of this function goes here
%   Detailed explanation goes here
%make a image;
Image = uint8(zeros(Isize(1),Isize(2),3));
for j = 1:3
    Image(:,:,j) = color(j);
end
end

