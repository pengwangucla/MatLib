function DrawRect(image,rect,path,file,img_format,choise,colorname)

if ~exist('choise','var')
    choise = [1,1];
end

[height,width,dim] = size(image);
row1 = rect(1);
row2 = rect(2);
col1 = rect(3);
col2 = rect(4);

colortype = [255,255,255; 0,0,0;255,0,0;0,255,0;0,0,255];
if ~exist('colorname','var')
    colorname = 'w';
end

switch colorname
    case 'w'
        colorid = 1;
    case 'k'
        colorid = 2;
    case 'r'
        colorid = 3;
    case 'g'
        colorid = 4;
    case 'b' 
        colorid = 5;
end


rect_img = image(row1:row2,col1:col2,:);
if choise(1)
    imwrite(rect_img,[path,file,'_part.',img_format],img_format);
end

pos = [row1,row2,col1,col2];
k = 1;
tempimg = image;

for rr = -k:k
    row1 = pos(1) + rr;
    row2 = pos(2) - rr;
    col1 = pos(3) + rr;
    col2 = pos(4) - rr;
    
    bound = [];
    bound = [row1:row2;ones(1,row2-row1+1)*col1]';
    bound = [bound;[row1:row2;ones(1,row2-row1+1)*col2]'];
    bound = [bound;[row1*ones(1,col2-col1+1);col1:col2]'];
    bound = [bound;[row2*ones(1,col2-col1+1);col1:col2]'];
    bound = uint32(bound);
    index = sub2ind([height,width],bound(:,1),bound(:,2));
    for i = 1:dim
        channel = tempimg(:,:,i);
        channel(index) = colortype(colorid,i);
        tempimg(:,:,i) = channel;
    end
end

if choise(2)
    imwrite(tempimg,[path,file,'_rect.',img_format],img_format);
end
