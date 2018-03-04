%% change box in an image to 
function boxpoints = box2ind(boxes, sz)
% boxes:  up left dowm bottom 
for ibox = 1:size(boxes,1)
   [x,y] = meshgrid(boxes(ibox,2):boxes(ibox,4), boxes(ibox,1):boxes(ibox,3));
   boxpoints = sub2ind2(sz, [y(:), x(:)]);
end
end
