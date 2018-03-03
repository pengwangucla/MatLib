function [evl, varargout] = EvaluateNormal(predset, gtset, varargin)

opt = struct('jumpNonExist', 1, 'use_py', 0, ...,
    'vis', 0, 'dataType', 'png', 'mask_set', [], 'plane_eval', 0, 'fieldname', 'normal');
opt = CatVarargin(opt, varargin);

% x point right,  y point up, z point inside 
if opt.use_py
    cmd = sprintf('python EvaluateNormal.py -c %s -g %s -l %s', opt.res_path, opt.gt_path, opt.list_file);
    fprintf('%s\n', cmd);
    system(cmd);
else 
    degree = [];
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
        
        mask = ~(gt_img(:,:,1) == -1 & gt_img(:,:,2) == -1); 
        mask2 = ~(res_img(:,:,1) == -1 & res_img(:,:,2) == -1); 
        if ~all((size(mask) - size(mask2))==0)
            mask2 = imresize(mask2, size(mask), 'nearest'); 
            mask = mask | mask2; 
        end
        
        if isfield(opt, 'sz');
            opt.method = 'nearest';
            [gt_img, res_img] = Resize2Same([{gt_img}, {res_img}], opt);
            opt.method = 'nearest'; 
            mask = imresize(mask, opt.sz, 'nearest'); 
        end
        
        if opt.sliceAsEigen
            mask(415:end, :) = 0; 
        end
        
        if ~all((size(res_img) - size(gt_img))==0)
            res_img = imresize(res_img, size(gt_img(:,:,1)), 'bilinear');
            res_img = NormalizeNorm(res_img); 
        end
        
        [gt_img, gt_norm] = NormalizeNorm(gt_img);
        [res_img, res_norm] = NormalizeNorm(res_img);
        
        % this is the mask we need to compare 
        mask = mask & (res_norm > 0 & gt_norm > 0); % gt_img(:,:,3) > 0 &  
        
        if ~isempty(opt.mask_set) & opt.plane_eval
            mask = mask & opt.mask_set{iimg}>0;
        end
        
        if opt.vis
            subplot_tight(1,3,1); imshow((gt_img+1)/2);
            subplot_tight(1,3,2); imshow((res_img+1)/2);
            subplot_tight(1,3,3); imshow(mask);
            pause;
        end
        
        in_prod = sum(gt_img.*res_img, 3);
        degree = [degree; (acos(in_prod(mask))*180/pi)];
        if nargout > 1
            varargout{1}(iimg) = mean(acos(in_prod(mask))*180/pi); 
        end
        
    end
end

fprintf(['%10s %10s  %10s  %10s  %10s \n'...,
     '%10.4f, %10.4f, %10.4f, %10.4f, %10.4f\n'], ...,
     'mean', 'media', '11.25', '22.5', '30', ...,
     mean(degree), median(degree), mean(degree<11.25), mean(degree<22.5), mean(degree<30));
     
evl.mean_d = mean(degree);
evl.med_d = median(degree); 
evl.the_1 = mean(degree<11.25); 
evl.the_2 = mean(degree<22.5); 
evl.the_3 = mean(degree<30); 

end

function ns = transform(ns)

ns = double(ns)*2/255-1;

end