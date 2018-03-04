function img = Resize2Maxlen(oimg, maxlen, method)
% Resize original image into a max length 
if ~exist('method','var'); method = 'bicubic'; end 
[height,width,~] = size(oimg);
img = oimg;
if length(maxlen) == 1
     ratio = maxlen/max(height,width);
     new_height = min(ratio*height, maxlen); 
     new_width = min(ratio*width, maxlen); 
     img = imresize(oimg,[new_height, new_width],method);
elseif length(maxlen) == 2
        ratio_height = maxlen(1)/height; 
        ratio_width = maxlen(2)/width; 
        ratio = min(ratio_height, ratio_width); 
        new_height = min(maxlen(1), ratio *height); 
        new_width = min(maxlen(2), ratio *width); 
        img = imresize(oimg,[new_height, new_width],method);
else
    error('not available resizing');
end
