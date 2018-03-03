function [img2, pos] = Peng_Imrotate(img, angle)
% rotate image with known the original pos in counter clock wise 
theta = angle*pi/180; 
R = [cos(theta), -sin(theta); sin(theta), cos(theta)]; 
[height,width, dim] = size(img); 
center = ceil([width,height]/2);
[x,y] = meshgrid(1:width, 1:height); 
x2 = x - center(1); 
y2 = y - center(2); 
pos = round(R*[x2(:)';y2(:)']); 
pos(1,:) = pos(1,:) + center(1); 
pos(2,:) = pos(2,:) + center(2);

ind = pos(1,:) > 0 & pos(1,:)<=width & pos(2,:) > 0 & pos(2,:) <=height; % valid id 

img2 = zeros(height*width, dim, 'uint8'); 
px2_ind = sub2ind([height,width], y(ind), x(ind)); 
px_ind = sub2ind([height,width], pos(2,ind), pos(1,ind)); 
img = reshape(img, [height*width, dim]); 
img2(px2_ind,:) = img(px_ind,:); 
img2 = reshape(img2, [height,width,dim]); 
pos(:, ~ind) = 0; 
pos = reshape(pos', [height,width,2]); 


end