function BigImg = GenBigImg(imgset,Rnumber);
if ~exist('option','var')
    option.imsize = [100,100];
    option.space = 10;
end

height = option.imsize(1);
width = option.imsize(2);
space = option.space;
Cnumber = length(imgset)/Rnumber;
BigImg = 255*ones(height*Rnumber+space*(Rnumber-1),width*Cnumber+space*(Cnumber-1),dim);

for i = 1:Rnumber 
    srow = (height+space)*(i-1)+1;
    erow = height*i+space*(i-1);
    for j = 1:Cnumber
        scol = (width+space)*(j-1)+1;
        ecol = width*j+space*(j-1);
        img =  imgset{Cnumber*(i-1)+j};
        img = imresize(img,[height,width],'nearest');
        BigImage(srow:erow,scol:ecol,:) = img;
    end
end