function [map, points, rect] = GetSurrondingMapFromPoints(points, opt); 
% points:  x, y 

x1 = min(points(:,1)); 
y1 = min(points(:,2)); 
x2 = max(points(:,1));
y2 = max(points(:,2)); 


left_dis = min([(x1-1), opt.dmax]); 
up_dis = min([y1-1, opt.dmax]); 
right_dis = min([opt.imsize(2)-x2, opt.dmax]); 
down_dis = min([opt.imsize(1)-y2, opt.dmax]); 



height = y2-y1+1+up_dis+down_dis;
width = x2-x1+1+ left_dis+  right_dis; 

map = false(height,width); 
points(:,1) = points(:,1) - x1 + 1 + left_dis; 
points(:,2) = points(:,2) - y1 + 1 + up_dis; 
ind = sub2ind([height,width], points(:,2), points(:,1)); 
map(ind) = 1; 


rect = [x1-left_dis, y1-up_dis, x2+right_dis, y2+down_dis]; 

end