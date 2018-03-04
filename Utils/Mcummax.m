function output = Mcummax(matrix_in, dim)

output = matrix_in;
if dim == 1
    mmax = zeros(1,size(matrix_in,2));
    for i = 1:size(matrix_in, dim)
        cur = matrix_in(i,:);
        output(i,:) = max([cur; mmax],[],1);
        mmax = output(i,:);
    end
else
    mmax = zeros(size(matrix_in,1),1);
    for i = 1:size(matrix_in, dim)
        cur = matrix_in(:,i);
        output(:,i) = max([cur, mmax],[],2);
        mmax = output(:,i);
    end
end
end
