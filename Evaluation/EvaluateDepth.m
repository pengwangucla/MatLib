function score = EvaluateDepth(predset, gtset, varargin)
% author: Peng Wang
% opt
%       rescale: shift to the ground truth mean

opt = struct('rescale',0, 'jumpNonExist', 1, 'saveErr', 0, 'cropboarder', 0, 'isNYU', 0, ...,
    'mask_set', [], 'plane_eval', 0);
% mask set is the set that

opt = CatVarargin(opt, varargin);

assert(length(predset) == length(gtset));
testnum = length(predset);

imageCounter = 1;
if ~isempty(opt.mask_set); assert(length(opt.mask_set) == testnum);  end

for i=1:testnum
    
    CountID(i, testnum, 100, 'evaluating:');
    % display progress
    
    imname = predset{i};
    gtname = gtset{i};
    %  imname
    if opt.jumpNonExist
        if ~exist(imname,'file') | ~exist(gtname, 'file');         continue;        end
    end
    
    if strcmp(imname(end-2:end), 'mat')
        % in the original scale
        resim = load(imname);
        resim = resim.(opt.fieldname);
        assert(sum(sum(isnan(resim))) == 0);
    else
        resim = im2double(imread(imname))*10; % 255 quantization
    end
    if strcmp(gtname(end-2:end), 'mat')
        gtim = load(gtname, 'depth');
        gtim = gtim.depth;
    else
        gtim = im2double(imread(gtname))*10;
    end
    
    % NYU make two different size it is so arkward
    if opt.isNYU
        sz_o = [480, 640]; % original size
        sz = [427, 561]; % new size;
        if size(gtim,1) == sz_o(1)
            gtim = crop_image(gtim);
        end
        if opt.cropboarder % haven't cropped images
            resim = imresize(resim, sz_o, 'bilinear');
            resim = crop_image(resim);
        else % already cropped results
            resim = imresize(resim, sz, 'bilinear');
        end
        if opt.sliceAsEigen
            resim(414:end,:) = 0; 
        end
    end
    
    if isfield(opt, 'sz')
        opt.method = 'bilinear';
        [resim, gtim] = Resize2Same([{gtim}, {resim}], opt);
    end
    
    if opt.blur
        h = fspecial('gaussian', 10, 4);
        resim = imfilter(resim, h, 'replicate', 'same');
    end
    
    Nocompareid = gtim == 0 | resim == 0;
    if ~isempty(opt.mask_set) & opt.plane_eval
        Nocompareid = Nocompareid | ~(opt.mask_set{i}>0);
    end
    comparePix = gtim ~= 0;
    
    myMinDepth = min(resim(comparePix(:)));
    minDepth = min(gtim(comparePix(:)));
    resim(Nocompareid ) = minDepth;
    gtim(Nocompareid ) = minDepth;
    
    if opt.rescale
        if i == 1;  fprintf('You are using the ground truth mean\n'); end
        depthind = resim > 0 & gtim > 0;
        shift = mean(resim(depthind )) - mean(gtim(depthind ));
        resim = resim - shift;
    end
    
    if opt.vis
        subplot_tight(2,2,1);  imshow(abs(gtim-resim)); freezeColors
        subplot_tight(2,2,4);  imshow(~Nocompareid); freezeColors
        subplot_tight(2,2,2);  imagesc(resim*255/10); colormap('jet'); axis off; axis('image'); freezeColors
        subplot_tight(2,2,3);  imagesc(gtim*255/10); colormap('jet'); axis off; axis('image'); freezeColors
        fprintf('%s\n', gtname);
        % print('-painters', '-dpng', [predset{i}(1:end-4), '.png']);
        pause;
    end
    
    if imageCounter == 1
        sz = size(resim);
        depthEst = zeros(sz(1),sz(2),1); %Estimated depth from DepthTransfer
        depthTrue = zeros(sz(1),sz(2),1); %Ground truth depth from dataset
        delta_each = zeros(1,3);
        rel = zeros(1);
        rel_sqr = zeros(1);
        pixnum = zeros(1);
        lg10 = zeros(1);
        rmse = zeros(1);
        rmse_log = zeros(1);
        
        RSME_grad = zeros(1,2,'single');
        if opt.saveErr
            ErrMap = zeros(opt.sz(1), opt.sz(2), 1, 'single');
        end
    end
    
    % rel_each(imageCounter) = mean(mean( abs(resim-gtim)./gtim, 2),1);
    pixnum(imageCounter,1) = numel(resim(~Nocompareid(:)));
    delta_each(imageCounter,1) = sum(max(resim(~Nocompareid(:))./gtim(~Nocompareid(:)), ...,
        gtim(~Nocompareid(:))./resim(~Nocompareid(:))) < 1.25)/pixnum(imageCounter);
    delta_each(imageCounter,2) = sum(max(resim(~Nocompareid(:))./gtim(~Nocompareid(:)), ...,
        gtim(~Nocompareid(:))./resim(~Nocompareid(:))) < 1.25^2) /pixnum(imageCounter) ;
    delta_each(imageCounter,3) = sum(max(resim(~Nocompareid(:))./gtim(~Nocompareid(:)), ...,
        gtim(~Nocompareid(:))./resim(~Nocompareid(:))) < 1.25^3) /pixnum(imageCounter) ;
    
    % gradient evaluation
    if opt.compare_Gradient
        hdiffRes = diff(resim,1,2);
        hdiffGT = diff(gtim,1,2);
        vdiffRes = diff(resim,1,1);
        vdiffGt = diff(gtim,1, 1);
        CompareID_Gradh = diff(Nocompareid,1,2) == 0 & ~Nocompareid(:,1:end-1);
        CompareID_Gradv = diff(Nocompareid,1,1) == 0 & ~Nocompareid(1:end-1,:);
        RSME_grad(imageCounter,1) = sum(abs(hdiffRes(CompareID_Gradh(:) ) - hdiffGT(CompareID_Gradh(:))))/sum(CompareID_Gradh(:));
        RSME_grad(imageCounter, 2) = sum(abs(vdiffRes(CompareID_Gradv(:)) - vdiffGt(CompareID_Gradv(:))))/sum(CompareID_Gradv(:));
        % region-wise depth relative
    end
    
    %depthEst(:,:,imageCounter) = resim;
    %depthTrue(:,:,imageCounter) = gtim;
    rel(imageCounter) = sum(abs(resim(~Nocompareid(:))-gtim(~Nocompareid(:)))./gtim(~Nocompareid(:)));
    rel_sqr(imageCounter) = sum((resim(~Nocompareid(:))-gtim(~Nocompareid(:))).^2./gtim(~Nocompareid(:)));
    lg10(imageCounter) = sum(abs(log10(resim(~Nocompareid(:)))-log10(gtim(~Nocompareid(:)))));
    rmse(imageCounter) = sum((resim(~Nocompareid(:))-gtim(~Nocompareid(:))).^2);
    rmse_log(imageCounter) = sum((log(resim(~Nocompareid(:)))-log(gtim(~Nocompareid(:)))).^2);
    
    % output the error map
    if opt.saveErr
        % compare with gt image for check the most error happend place
        ErrMap(:,:,imageCounter) = abs(resim - gtim);
    end
    
    imageCounter  = imageCounter  + 1;
end

fprintf('Evaluated image number %d \n', imageCounter-1 );
delta = sum(delta_each.*repmat(pixnum,[1,3]),1)./sum(pixnum);
delta = delta*100;

rel = sum(rel)/sum(pixnum);
rel_sqr = sum(rel_sqr)/sum(pixnum);
lg10 = sum(lg10)/sum(pixnum);
rmse = sqrt( sum(rmse)/sum(pixnum)  );
rmse_log = sqrt( sum(rmse_log)/sum(pixnum));

% fprintf(['\nError averaged over all test data\n', ...
%     '=================================\n', ...
%     '%10s %10s %10s %10s %10s %10s \n'...,
%     '%10.4f %10.4f %10.4f  %10.4f,  %10.4f   %10.4f \n'], ...
%     'relative', 'log10', 'rmse', 'delta < 1.25','delta < 1.25^2','delta < 1.25^3',...,
%     mean(rel), mean(lg10), mean(rmse),  delta(1), delta(2), delta(3));

fprintf(['\nError averaged over all test data\n', ...
    '=================================\n', ...
    '%10s %10s %10s %10s %10s %10s %10s %10s \n'...,
    '%10.4f %10.4f %10.4f %10.4f  %10.4f  %10.4f   %10.4f   %10.4f \n'], ...
    'relative', 'relative_sqr', 'log10', 'rmse', 'rmse_log', 'delta < 1.25','delta < 1.25^2','delta < 1.25^3',...,
    (rel), (rel_sqr), (lg10), (rmse), (rmse_log), delta(1), delta(2), delta(3));

if opt.compare_Gradient
    fprintf(['\nGradient error averaged over all test data\n', ...
        '=================================\n', ...
        '%10s %10s  \n'...,
        '%10.4f %10.4f  \n'], ...
        'rmae_hoz', 'rmae_ver', ...,
        mean(RSME_grad(:,1)), mean(RSME_grad(:,2)));
end
score.imageCounter = imageCounter-1; 
score.rel = rel;
score.rel_sqr =rel_sqr; 
score.log10 = lg10;
score.rmse = rmse;
score.rmse_log =rmse_log; 
score.delta = delta; 

end