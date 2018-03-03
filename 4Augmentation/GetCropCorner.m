function crops = GetCropCorner(sz, opt);
% get the crop left top corners for cropping data augmentation 
% frist line is the original size, the rest are the cropping sizes '
% sz output the height width respect to each left up corner 
if ~exist('opt', 'var')
    opt = struct('randCrop', 0, 'randnum', 10); 
end 

crops = zeros(4*(size(sz,1)-1),4, 'single');  % up left height,width, center of each cropping box 
for isz = 2:size(sz,1)
    range = (isz-2)*5+1: (isz-1)*5; 
    crops(range, 1:2) = [0,0; 0, sz(1,2)-sz(isz,2); ...,
        sz(1,1)-sz(isz,1), 0; sz(1,1)-sz(isz,1),sz(1,2)-sz(isz,2);...,
        [sz(1,1)-sz(isz,1),sz(1,2)-sz(isz,2)]/2];
    crops(range, 3:4) = repmat(sz(isz,:), [5,1]); 
end

% add more random cropping from the first cropping 
if opt.randCrop
    randnum= opt.randnum; 
    range_h = sz(1,1)-sz(2,1);
    range_w = sz(1,2)-sz(2,2);
    crops_rand = zeros(randnum, 4, 'single');
    crops_rand(:,1:2) = ceil([rand(randnum,1)*range_h, rand(randnum,1)*range_w]);
    crops_rand(:,3:4) =  repmat(sz(2,:), [randnum,1]);
    crops = [crops; crops_rand];
end

end