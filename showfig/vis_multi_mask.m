function new_img = vis_multi_mask(img, masks, colors)
% img: M*N*3
% masks: M*N*K
% colors: K*3, <= 255 
if max(colors(:)) <=1
    colors = round(colors*255);
end
if size(masks, 1) ~= size(img,1 ) | size(masks, 2) ~= size(img, 2) ;
    masks = imresize(masks,[size(img,1), size(img,2)], 'nearest');
end


[height,width,masknum] = size(masks);
if masknum == 1
    labels = unique(masks(:));
    labels(labels == 0) = [];
    masknum = length(labels);
    tmp_masks = false(height,width,masknum);
    for i = 1:masknum;
        tmp_masks(:,:,i) = masks == labels(i);
    end
    masks = tmp_masks;
end

%if length(masknum) ~= masknum;
if ~exist('labels','var')
    labels = (1:masknum);
end
mycolors = zeros(masknum,3);
for i = 1:masknum;
    mycolors(i,:) = colors(labels(i)+1,:);
end
colors = mycolors;
%end

img = double(img);
masks = logical(masks);
colors = double(colors);

transp = 0.4;%0.5;
new_img = img;
for ii = 1:size(masks,3)
    try
        new_img = vis_mask(new_img, masks(:,:,ii), colors(ii,:), transp);
    catch
        disp('r'); 
    end
end

line_width = 1;
edge_imgs = false(size(masks));
for j = 1:size(masks,3)
    b = cell2mat(bwboundaries(masks(:,:,j)));
    one_edge = zeros(size(img,1), size(img,2));
    try
        ind = sub2ind([size(img,1) size(img,2)], b(:,1), b(:,2));
    catch
        disp('r');
    end
    
    one_edge(ind) = 1;
    
    for t = 1:line_width
        one_edge = bwmorph(one_edge, 'dilate');
    end
    
    edge_imgs(:,:,j) = logical(one_edge);
end

for ii = 1:size(masks,3)
    for j = 1:3
        newI_j = new_img(:,:,j);
        newI_j(edge_imgs(:,:,ii)) = colors(ii,j);
        new_img(:,:, j) = newI_j;
    end
end

% imshow(new_img, 'Border', 'tight');
end
