
function [data, label, counter] = ResetBuffer(width,height,MapNum, batchsize)

counter = 0;
data = zeros(width, height, 3, batchsize, 'single');
label = zeros(width, height, MapNum, batchsize, 'single');

end