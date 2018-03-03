function score= EvaluateDepth_plane(predset, gtset, varargin)
% evaluate the depth property over the plane instances

opt = struct('rescale',0, 'jumpNonExist', 1, 'saveErr', 0, ...,
    'cropboarder', 0, 'isNYU', 0, 'mask_set', [], 'erode', 3, 'overwrite', 0);
% mask set is the set that

opt = CatVarargin(opt, varargin);
assert(length(predset) == length(gtset));
testnum = length(predset);

imageCounter = 1;

diff_2o = zeros(testnum,1);
pixnum = zeros(testnum,1);
var_all = zeros(testnum,1);
degree_var_all = [];
for i=1:testnum
    
    CountID(i, testnum, 100, 'evaluating:');
    % display progress
    
    imname = predset{i};
    gtname = gtset{i};
    %  imname
    if opt.jumpNonExist
        if ~exist(imname,'file') | ~exist(gtname, 'file');         continue;        end
    end
    
    switch opt.dataType
        case 'png'
            resim = im2double(imread(imname))*10; % 255 quantization
            
        case 'mat'
            % in the original scale
            resim = load(imname);
            resim = resim.(opt.fieldname);
            % resim = im2double(uint8(resim*255/10))*10;
            assert(sum(sum(isnan(resim))) == 0);
    end
    
    if strcmp(gtname(end-2:end), 'mat')
        gtim = load(gtname, 'depth');
        gtim = gtim.depth;
    else
        gtim = im2double(imread(gtname))*10;
    end
    
    % NYU make two different size it is so arkward
    if opt.isNYU
        sz_o = size(gtim); % original size
        gtim = crop_image(gtim);
        sz = size(gtim); % new size;
        
        if opt.cropboarder % haven't cropped images
            resim = imresize(resim, sz_o, 'bilinear');
            resim = crop_image(resim);
        else % already cropped results
            resim = imresize(resim, sz, 'bilinear');
        end
    end
    
    if isfield(opt, 'sz')
        opt.method = 'bilinear';
        [resim, gtim] = Resize2Same([{resim}, {gtim}], opt);
    end
    
    if opt.blur
        h = fspecial('gaussian', 10, 4);
        resim = imfilter(resim, h, 'replicate', 'same');
    end
    
    Nocompareid = gtim == 0 | resim == 0;
    
%     if ~isempty(opt.mask_set);
%         Nocompareid = Nocompareid | ~opt.mask_set{i};
%     end
    
    comparePix = gtim ~= 0;
    
    minDepth = min(gtim(comparePix(:)));
    resim(Nocompareid ) = minDepth;
    gtim(Nocompareid ) = minDepth;
    
    if opt.sliceAsEigen
        Nocompareid(415:end,:) = 1;
    end
    
    if opt.vis
        subplot_tight(2,2,1);  imshow(abs(gtim-resim)); freezeColors
        subplot_tight(2,2,4);  imshow(~Nocompareid); freezeColors
        subplot_tight(2,2,2);  imagesc(resim*255/10); colormap('jet'); axis off; axis('image'); freezeColors
        subplot_tight(2,2,3);  imagesc(gtim*255/10); colormap('jet'); axis off; axis('image'); freezeColors
        
        pause;
    end
    
    plane = opt.mask_set{i};
    plane(Nocompareid) = 0;
    if opt.vis
        imagesc(plane);
        pause;
    end
    
    planeid = unique(opt.mask_set{i});
    planeid(planeid == 0 ) = [];
    resim = resim*100;
    grad_v = abs([zeros(2, size(resim,2)); diff(resim,2,1)]);
    grad_h = abs([zeros(size(resim,1),2),diff(resim,2,2)]);
    grad_v(Nocompareid) = 0;
    grad_h(Nocompareid) = 0;
    
    % generate normal map from the depth map and evaluate that inside each
    % plane instance
    
    if ~exist([imname(1:end-4), '_normal',opt.fieldname,'.mat'], 'file') | opt.overwrite
        res= zeros([size(resim),3]);
        [~, normal_depth, ~]  = depth2normal(resim, opt.mask_source, opt);
        res(1:opt.masksz(1),1:opt.masksz(2), :) = NormalizeNorm(normal_depth, opt);
        res = single(res); 
        save([imname(1:end-4), '_normal',opt.fieldname,'.mat'], 'res');
    else
        load([imname(1:end-4), '_normal',opt.fieldname,'.mat']);
    end
    
    res = reshape(res, [numel(resim),3]);
    % plane = plane &
    
    for iplane = 1:length(planeid)
        mask = plane == planeid(iplane);
        mask = imerode(mask, strel('disk',opt.erode)); % remove the effect of boundary
        
        pixnum_cur =  sum(mask(:));
        if pixnum_cur == 0; continue; end 
        mean_n = mean(res(mask(:), :));
        mean_n = mean_n/norm(mean_n);
        degree_var = degreediff(res(mask(:), :), repmat(mean_n, [pixnum_cur, 1]));
        
        if opt.vis
            close all;
            temp = zeros(size(mask));
            temp(mask) = degree_var;
            imshow(temp, []);
            pause;
        end
        
        % pixnum(iimg) = pixnum(iimg) + sum(mask(:));
        var_all(i) = var_all(i)+sum(degree_var);
        degree_var_all = [degree_var_all; degree_var];
        diff_2o(i) = diff_2o(i) + (sum(grad_v(mask)+grad_h(mask)));
        pixnum(i) = pixnum(i) +pixnum_cur;
    end
    
    imageCounter  = imageCounter  + 1;
end

fprintf('Evaluated image number %d \n', imageCounter-1 );
mean_o2d = sum(diff_2o)/sum(pixnum);
degree_mean_var = sum(var_all)/sum(pixnum);
degree_median_var = median(degree_var_all);

fprintf(['%10s %10s %10s\n'...,
    '%10.4f, %10.4f, %10.4f\n'], ...,
    'digree var mean', 'digree var med', 'o2p grad', ...,
    degree_mean_var, degree_median_var, mean_o2d);

score.o2d = mean_o2d;

score.degree_mean = degree_mean_var;



