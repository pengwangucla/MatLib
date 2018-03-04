function [edge bound] = show_boundary(img,index,color,center,option)
if ~exist('option','var')
    option.dilate = 0;
end
if ~exist('color','var')
    color = 'k';
end
if ~exist('center','var');
    center = [];
end
if size(img, 1) ~= size(index,1) | size(img, 2) ~= size(index,2);
    index = imresize(index, [size(img,1 ), size(img,2 )], 'nearest');
end

index=  double(index);
edge = img;
[height,width,dim] = size(img);
if dim == 1
    img = repmat(img,[1,1,3]);
end

pixelnum = height*width;
Regions = reshape(index,[height, width]);
temp_index = Regions(:,2:width)- Regions(:,1:width-1);
hbound = temp_index ~= 0;

hbound(:,width) = logical(zeros(height,1));
%     imshow(hbound);
%     pause

temp_index =  Regions(2:height,:)-Regions(1:height-1,:);
vbound = temp_index ~= 0;
vbound(height,:) = logical(zeros(1,width));

bound = hbound | vbound;
if option.dilate 
    line_width = 2;
    for t = 1:line_width
        bound = bwmorph(bound, 'dilate');
    end
end


colorrec = [0,0,0;255,0,0;0,255,0;255,255,255];

for i = 1:3
    tempimg = img(:,:,i);
    if ischar(color)
        switch color
            case 'k'
                tempimg(bound) = colorrec(1,i);
            case 'r'
                tempimg(bound) = colorrec(2,i);
            case 'w'
                tempimg(bound) = colorrec(4,i);
        end
    else
        tempimg(bound) = color(i);
    end
    edge(:,:,i) = tempimg;
end

if isempty(center)
    return;
else
    showness = 2;
    center(:,1) = min(max(center(:,1),3),height-3);
    center(:,2) = min(max(center(:,2),3),width-3);
    
    switch showness
        case 1
            edge = plot_center(edge,center,color,'x');
        case 2
            edge = plot_center(edge,center,color,'+');
    end
    
end
end