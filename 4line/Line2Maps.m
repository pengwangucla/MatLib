function [ maps, pos ] = Line2Maps( points, varargin )
%LINE2PIXEL Summary of this function goes here
%   Convert a line to a pixel map 
%  points : nx4 points for n line segments 

opt = struct('map_type', 'single', 'imsize', ceil([max(points(:,4)), max(points(:,3))])); 
opt = CatVarargin(opt, varargin); 
% constraint into opt.imsize
points(:,1) = max(min(points(:,1), opt.imsize(2)), 1); 
points(:,3) = max(min(points(:,3), opt.imsize(2)), 1); 
points(:,2) = max(min(points(:,2), opt.imsize(1)), 1); 
points(:,4) = max(min(points(:,4), opt.imsize(1)), 1); 

[~,axis] = max([abs(points(:,3)-points(:,1)), abs(points(:,4)-points(:,2))], [], 2); 
switch opt.map_type
    case 'single'
        maps = zeros(opt.imsize, 'single'); 
    case 'multi'
        maps = false([opt.imsize, size(points,1)]); 
end

pos = cell(size(points, 1),1); 

for iline = 1:length(axis)
    if axis == 1
        s = floor(min(points(iline, 1), points(iline,3))); 
        e = floor(max(points(iline, 1), points(iline,3))); 
        x = max(floor(s:e),1); 
        y = floor((points(iline,4)-points(iline,2))/(points(iline,3)-points(iline,1))...,
            *(x-points(iline, 1)) + points(iline, 2));
    else
       s = floor(min(points(iline, 2), points(iline,4))); 
       e = floor(max(points(iline, 2), points(iline,4))); 
       y = max(floor(s:e),1); 
       x = floor((points(iline,3)-points(iline,1))/(points(iline,4)-points(iline,2))...,
            *(y-points(iline, 2)) + points(iline, 1)); 
    end
    x = max(x,1); 
    y = max(y,1); 
    pos{iline} = [x;y]; 
    
    ind = sub2ind(opt.imsize, y, x); 
    switch opt.map_type
        case 'single'
            maps(ind) = iline; 
        case 'multi'
           temp = maps(:,:,iline); 
           temp(ind) = 1; 
           maps(:,:,iline) = temp; 
    end
end


end

