function filtedImg = depthFilter_v2(img, depthMap, varargin);

opt = struct('FocusPos', [], 'magnitude', [], 'range', 1);
opt = CatVarargin(opt, varargin);

if ~isa(img, 'uint8'); error('must be uint8 img'); end 

[height,width, dim] = size(img);
if ~isfield(opt, 'FocusPos');  opt.FocusPos = [height/2, width/2]; end
if ~isfield(opt, 'magnitude'); opt.magnitude = 0.05; end
if ~isfield(opt,'maxSigma'); opt.maxSigma = 20; end

opt.FocusPos = round(opt.FocusPos);
img = im2double(img);
depthMap = double(depthMap);
if size(depthMap,1) ~= height | size(depthMap,2) ~= width
    depthMap = imresize(depthMap,[height,width]);
end
if ~isfield(opt, 'Focus')
    Focus = depthMap(opt.FocusPos(1), opt.FocusPos(2));
else
    Focus = double(opt.Focus);
end

maxDepth = max(depthMap(:));
sigma = opt.magnitude*(abs(depthMap(:) - Focus)/opt.range);
% sigma(depthMap(:) == 0.1) = opt.magnitude*abs(maxDepth-Focus);

% load filters
maxSigma = double(floor(max(sigma)));
%sigma = log(sigma+1);
if maxSigma > opt.maxSigma
    factor = opt.maxSigma/maxSigma;
    % sigma = log(sigma+1);
    sigma = sigma*factor;
end

sigma = floor(sigma);
ind_nofilt = sigma < 1;

[sigmaLabel,~,ic] = unique(sigma);
filtedImg = zeros(height*width, dim);
img = reshape(img, [height*width, dim]);
filtedImg(ind_nofilt(:),:) = img(ind_nofilt(:),:);
compenseImg = img;
compenseImg(ind_nofilt(:),:) = 0;
ind_nofilt = reshape(ind_nofilt,[height,width]);
patchsz = max(2*max(sigmaLabel)+1,21);

for icolor = 1:dim
    % tempmap = reshape(img(:,icolor), [height,width]); 
    
    tempmap = compenseImg(:,icolor);
    tempmap = reshape(tempmap, [height,width]);
    tempmap = PatchExpand(tempmap, ~ind_nofilt, patchsz);
    
    for isigma = 1:length(sigmaLabel);
        if sigmaLabel(isigma) == 0; continue; end
        
        ind_real = ic == isigma;
        %     ind_dilate = imdilate(ind_real,se );
        %     map = zeros(height*width, dim);
        %     map(ind_dilate(:), :) = img(ind_dilate(:),:);

        h = fspecial('disk',sigmaLabel(isigma));

        %    se = strel('disk',2*sigmaLabel(isigma));
        %     imshow(tempmap);
        
        tempmap = conv2(tempmap,h,'same');
%        assert(any(isnan(tempmap(:))) == 0); assert(any(isinf(tempmap(:))) == 0);
        filtedImg(ind_real(:),icolor) = tempmap(ind_real(:));
%         imshow(reshape(filtedImg,[height,width,dim]));
%         pause; 
    end
    
    % subplot_tight(1,2,1); imshow(reshape(tempmap,[height,width,dim]));
    %     imshow(reshape(filtedImg,[height,width,dim]));
    %    pause;
end
filtedImg = reshape(filtedImg, [height,width,dim]);
end

function map = PatchExpand(map, bwind, patchsz)
%bwind:  pixel inside map
if length(patchsz) == 1
    patchsz = [patchsz, patchsz];
end

% for a grey image 
[height,width,dim] = size(map);
edgemap = edge(bwind, 'canny');

idxBoundary = find(edgemap(:));
if isempty(idxBoundary); return; end 
[r, c] = ind2sub([height,width], idxBoundary); 
centerid  = [r,c];
centernum = size(centerid,1);
%samplenum = max(round(centernum*2/max(patchsz)),1);
%samplenum = 1;
%centerid = centerid(randperm(centernum, samplenum),:);

sz(1) = floor((patchsz(1)+1)/2);
sz(2) = floor((patchsz(2)+1)/2);

centerid(:,1) = centerid(:,1) + sz(1); % row
centerid(:,2) = centerid(:,2) + sz(2); %
map = paddingImg(map, sz);
bwind = paddingImg(bwind,sz); 

[patches, patchidx] = GetImgPatch(map, centerid, patchsz);
patchInpaintID = ~bwind(patchidx); % outside ind 

inpaintPatch = repmat(sum(patches, 2)./max(sum(~patchInpaintID,2), 1e-5),[1,size(patches,2)]); 
map(patchidx(patchInpaintID)) = inpaintPatch(patchInpaintID);
map = cropPadding(map, sz);
end

