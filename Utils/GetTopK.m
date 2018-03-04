function [val, id] = GetTopK(Mat, dim, k, direct)

% top k value of the matrix along given dim 

[val,id] = sort(Mat, dim, direct);
if dim == 1
    val = val(1:k, :);
    id = id(1:k,:);
else
    val = val(:,1:k);
    id = id(:,1:k);
end