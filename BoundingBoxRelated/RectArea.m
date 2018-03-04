function area = RectArea(rect)
% each row is a box 
area = (rect(:,3)-rect(:,1)).*(rect(:,4)-rect(:,2));