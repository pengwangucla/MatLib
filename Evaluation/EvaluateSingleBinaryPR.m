function [thresh,cntR,sumR,cntP,sumP]  = EvaluateSingleBinaryPR(pb, gt, prFile, varargin); 
% [thresh,cntR,sumR,cntP,sumP] = boundaryPR_image(inFile,gtFile, prFile, nthresh, maxDist, thinpb)
%
% Calculate precision/recall curve.
%
% INPUT
%	inFile  : Can be one of the following:
%             - a soft or hard boundary map in image format.
%             - a collection of segmentations in a cell 'segs' stored in a mat file
%             - an ultrametric contour map in 'doubleSize' format, 'ucm2'
%               stored in a mat file with values in [0 1].
%
%	gtFile	: File containing a cell of ground truth boundaries
%   prFile  : Temporary output for this image.
%	nthresh	: Number of points in PR curve.
%   MaxDist : For computing Precision / Recall.
%   thinpb  : option to apply morphological thinning on segmentation
%             boundaries.
%
% OUTPUT
%	thresh		Vector of threshold values.
%	cntR,sumR	Ratio gives recall.
%	cntP,sumP	Ratio gives precision.

opt = struct('nthresh', 33, 'maxDist', 0.0075, 'thinpb', 1, ...,
    'w_occ', 0, 'renormalize', 1, 'rank_score', [], 'debug', 0); 
opt = CatVarargin(opt, varargin); 
nthresh = opt.nthresh; 
maxDist = opt.maxDist; 
thinpb = opt.thinpb; 
rank_score = opt.rank_score; 

thresh = linspace(1/(nthresh+1),1-1/(nthresh+1),nthresh)';
% zero all counts

cntR = zeros(size(thresh));
cntP = zeros(size(thresh));
sumP = zeros(size(thresh));

pb_num = size(pb,3) ; 

if ~isempty(rank_score);
    pb(pb > 0) = rank_score(pb>0);   
end 

sumR = 0;
for i = 1:size(gt,3),
  sumR = sumR + sum(sum(gt(:,:,i)));
end
sumR = sumR .* ones(size(thresh));
% match1_all = zeros(size(gt)); 

for t = nthresh:-1:1, 
    % pb(pb<thresh(t)) = 0; 
    bmap = pb >= thresh(t); 
%     imshow(bmap); 
%     pause; 
    
    if t<nthresh,
        % consider only new boundaries
        bmap = bmap .* ~(pb>=thresh(t+1));
        % these stats accumulate
        cntR(t) = cntR(t+1);
        cntP(t) = cntP(t+1);
        sumP(t) = sumP(t+1);
    end
    
    % bmap = RmSmallEdge(bmap, 5);
    % accumulate machine matches, since the machine pixels are
    % allowed to match with any segmentation 
    accP = zeros(size(bmap));

    % compare to each seg in turn 
    for i = 1:size(gt,3),
        % compute the correspondence
        [match1, match2] = correspondPixels_Plane(double(bmap), double(gt(:,:,i)));
        
        gt(:,:,i) = gt(:,:,i).*~match2; 
       % compute recall
        cntR(t) = cntR(t) + sum(match2(:)>0); 
        accP = accP | match1; 

    end
    
    % compute precision
    sumP(t) = sumP(t) + sum(bmap(:));
    cntP(t) = cntP(t) + sum(accP(:));
end

% output
fid = fopen(prFile,'w');
if fid==-1,
    error('Could not open file %s for writing.', prFile);
end
fprintf(fid,'%10g %10g %10g %10g %10g\n',[thresh cntR sumR cntP sumP]');

fclose(fid);
end

function  [match1, match2] = correspondPixels_Plane(bmap, gt) 

match1 = bmap == 1 & gt == 1; 
match2 = match1; 

end

