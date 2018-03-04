function Colorimage = label2color_NYU(label, cmap);
labelid = unique(label(:));
[height,width,~] = size(label);
labelid (labelid == 0) = [];
labelnum = length(labelid);

Colorimage = zeros(height*width, 3);
for i = 1:labelnum 
    mask = label == labelid(i);
    Colorimage(mask(:),:) = repmat(cmap(labelid(i),:),[sum(mask(:)),1]);
end

Colorimage = reshape(Colorimage,[height,width, 3]);