function val = degreediff(in_1, in_2)
% compute the elementwise difference of degree by inputing the normal
% vectors 
% input must be nx3 3d vector 
dim  = ndims(in_1); 
assert(size(in_1,1) == size(in_2, 1)); 
inner = sum(in_1.*in_2, dim); 
val = real(acos(inner)*180/pi); 

end