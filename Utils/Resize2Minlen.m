function img = Resize2Minlen(oimg, minlen, method)
% Resize original image into a man lenth 
if ~exist('method','var'); method = 'bicubic'; end 
[height,width,~] = size(oimg);
img = oimg;
if length(minlen) == 1
    if min(height,width) < minlen
        ratio = minlen/min(height,width);
        img = imresize(oimg,ratio,method);
    end
elseif length(minlen) == 2
    if height < minlen(1) | width < minlen(2)
        img = imresize(oimg,minlen,method);
    end
else
    error('not available resizing');
end
