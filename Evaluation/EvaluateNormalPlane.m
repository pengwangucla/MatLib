function [evl, varargout] = EvaluateNormalPlane(predset, gtset, varargin)

opt = struct('jumpNonExist', 1, 'use_py', 0, 'vis', 0, ...,
    'dataType', 'png', 'mask_set', [], 'fieldname', 1);
opt = CatVarargin(opt, varargin);
% x point right,  y point up, z point inside

degree = [];
var_all = zeros(length(gtset),1); 
grad_all = var_all; 
pixnum_all = var_all; 
for iimg = 1:length(gtset);
    CountID(iimg, length(gtset), 100, 'evaluating');
    gt_img = transform(imread(gtset{iimg}));
    
    switch opt.dataType
        case 'png'
            res_img = transform(imread(predset{iimg}));
        case 'mat'
            load(predset{iimg}, opt.fieldname);
            eval(['res_img = ',opt.fieldname, '*2-1;']); 
    end
    
    if ~all((size(res_img) - size(gt_img))==0)
        res_img = imresize(res_img, size(gt_img(:,:,1)), 'bilinear');
    end
    
    mask = ~(gt_img(:,:,1) == -1 & gt_img(:,:,2) == -1); 
    mask = mask & ~(res_img(:,:,1) == -1 & res_img(:,:,2) == -1 & res_img(:,:,3) == -1); 
    

    if opt.vis
        subplot_tight(1,3,1); imshow(gtset{iimg});
        subplot_tight(1,3,2); imshow(predset{iimg});
        subplot_tight(1,3,3); imshow(mask);
        pause;
    end
    
    [gt_img, gt_norm] = NormalizeNorm(gt_img);
    [res_img, res_norm] = NormalizeNorm(res_img); 
    
    % this is the mask we need to compare
    mask = mask & (gt_img(:,:,3) > 0 & res_norm > 0 & gt_norm > 0);
    
    if ~isempty(opt.mask_set);
        mask = mask & opt.mask_set{iimg}>0;
    end
    
    [h, w, dim] = size(res_img);
    planeid = unique(opt.mask_set{iimg});
    planeid(planeid == 0 ) = [];
    
    grad_v = [zeros(1, size(res_img,2)); degreediff(res_img(2:end,:, :), res_img(1:end-1,:, :))];
    grad_h = [zeros(size(res_img,1),1), degreediff(res_img(:,2:end,:), res_img(:,1:end-1,:))];
    res = reshape(res_img, [h*w, dim]);
%     if opt.vis
%         subplot_tight(1,2,1); imshow(grad_v);
%         subplot_tight(1,2,2); imshow(grad_h);
%         pause; 
%     end
    plane = opt.mask_set{iimg}; 
    plane(~mask) = 0; 
    
    for iplane = 1:length(planeid)
        mask = plane == planeid(iplane);
        mask = imerode(mask, strel('disk',1))>0;
        pixnum = sum(mask(:));
        mean_n = mean(res(mask(:), :));
        mean_n = mean_n/norm(mean_n); 
        degree_var = degreediff(res(mask(:), :), repmat(mean_n, [pixnum, 1])); 
        if opt.vis
            close all; 
            temp = zeros(size(mask)); 
            temp(mask) = degree_var; 
            imshow(temp, []); 
            pause; 
        end
        
        grad_all(iimg) = grad_all(iimg) + (sum(grad_v(mask)) + sum(grad_h(mask)));
        % pixnum(iimg) = pixnum(iimg) + sum(mask(:));
        
        var_all(iimg) = var_all(iimg)+sum(degree_var);
        
        pixnum_all(iimg) = pixnum_all(iimg)+pixnum;
    end
end

degree_mean_var = sum(var_all)/sum(pixnum_all); 
degree_mean_grad = sum(grad_all)/sum(pixnum_all);
fprintf(['%10s %10s \n'...,
    '%10.4f, %10.4f\n'], ...,
    'digree var', 'digree mean grad', ...,
    degree_mean_var, degree_mean_grad);

evl.var_d = mean(degree_mean_var);
evl.grad_d = median(degree_mean_grad);

if nargout > 1
    % use for ranking the results 
    varargout{1} = var_all./pixnum_all; 
end

end



function ns = transform(ns)

ns = double(ns)*2/255-1;

end