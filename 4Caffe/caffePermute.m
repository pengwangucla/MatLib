function [img, varargout] = caffePermute(img, varargin)
model = struct('resize_method', 'crop', 'data_type', 'img', ...,
    'resize', 'bilinear', 'normalize_l2', 0); 
model = CatVarargin(model, varargin); 
if ndims(model.image_mean) == 3
    img_mean = imresize(model.image_mean, model.imgSize);     
else
    assert(length(model.image_mean) == 3); 
    img_mean  = repmat(model.image_mean(:)', [prod(model.imgSize),1]); 
    img_mean = reshape(img_mean, [model.imgSize, 3]); 
end

[height,width,~] = size(img); 
img = single(img);
switch model.data_type
    case 'img'
        img = img(:,:,[3 2 1]); % caffe uses BGR
        img = img - imresize(img_mean, [height,width], 'nearest');
    case 'eigen'
       
end

switch model.resize_method
    case 'warp'
        if  strcmp(model.resize, 'edge_resize'); 
            img = single(Resize_binary_edge_image(img,model.imgSize(1),model.imgSize(2))); 
            img = bwmorph(img,'clean');
            % img = imdilate(img, strel('disk',1)); 
            
            img = bwmorph(img,'bridge');
        else
            img = imresize(img, model.imgSize, model.resize);
        end
        
    case 'crop'
        img = Resize2Maxlen(img, model.imgSize, model.resize); 
        model.isAppend = 0; 
        [img, opt.mask] = paddingImg(img, model.imgSize, model) ; 
end

if model.normalize_l2
    assert(size(img, 3) == 3); 
    norm_term = max(sqrt(sum(img.^2, 3)), eps); 
    img = img./repmat(norm_term, [1,1,3]); 
end

img = permute(img, [2,1,3]);
if nargout > 1
    if ~isfield(opt, 'mask'); error('perhaps not set resized_method'); end 
    varargout{1} = single(permute(opt.mask, [2,1,3])); 
end
end