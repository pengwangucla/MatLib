function [thresh,cntR,sumR,cntP,sumP] = EvaluateSingle(pb, gt, prFile, varargin)
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

opt = struct('nthresh', 99, 'maxDist', 0.0075, 'thinpb', 1, ...,
    'w_occ', 0, 'renormalize', 1, 'rank_score', [], 'debug', 0); 
opt = CatVarargin(opt, varargin); 
nthresh = opt.nthresh; 
maxDist = opt.maxDist; 
thinpb = opt.thinpb; 
rank_score = opt.rank_score; 

thresh = linspace(1/(nthresh+1),1-1/(nthresh+1),nthresh)';
% zero all counts
if opt.w_occ
cntR_occ = zeros(size(thresh));
cntP_occ = zeros(size(thresh));
end
cntR = zeros(size(thresh));

cntP = zeros(size(thresh));
sumP = zeros(size(thresh));

pb_num = size(pb,3) ; 
if pb_num >= 2 && opt.w_occ
    occ = pb(:,:,2); 
    pb = pb(:,:,1); 
end

if size(gt,3) >= 2 && opt.w_occ
    % first is gt edge, second is gt occ 
    gt_occ = gt(:,:,2:2:end); 
    gt = gt(:,:,1:2:end); 
end

%
if thinpb
        pb = edge_nms(pb, 0);
        if opt.debug; imshow(1-pb); pause; end 
        if opt.w_occ
            [~, occ, pb, sim_score]  = Shrink2Edge(pb, occ, 0, 0, 'pix');
            rank_score = pb + sim_score;
        end
end

if ~isempty(rank_score);
    pb(pb > 0) = rank_score(pb>0);   
end 
    
if opt.renormalize
    id = pb > 0;  
    pb(id) = (pb(id) - min(pb(id)))/(max(pb(id))-min(pb(id))+eps); 
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
    
    if t<nthresh,
        % consider only new boundaries
        bmap = bmap .* ~(pb>=thresh(t+1));
        % these stats accumulate
        cntR(t) = cntR(t+1);
        cntP(t) = cntP(t+1);
        sumP(t) = sumP(t+1);
        
        if opt.w_occ
            cntR_occ(t) = cntR_occ(t+1); 
            cntP_occ(t) = cntP_occ(t+1); 
        end
    end
    
    % bmap = RmSmallEdge(bmap, 5);
    % accumulate machine matches, since the machine pixels are
    % allowed to match with any segmentation 
    accP = zeros(size(bmap));
    if opt.w_occ;  accP_occ = accP; end 
    % compare to each seg in turn 
    for i = 1:size(gt,3),
        % compute the correspondence
        [match1, match2] = correspondPixels(double(bmap), double(gt(:,:,i)), maxDist);
        
        if opt.w_occ
            % match1_all(:,:,i) = match1_all(:,:,i)+match1;
            % reserver the edge that also correct with directions 
            [match1_occ,match2_occ] = correspondOccPixels(match1, ...,
                occ, gt_occ(:,:,i));
        end
        
        gt(:,:,i) = gt(:,:,i).*~match2; 
       % compute recall
        cntR(t) = cntR(t) + sum(match2(:)>0); 
        accP = accP | match1; 
        
        if opt.w_occ 
            gt_occ(:,:,i) = gt_occ(:,:,i).*~match2; 
            cntR_occ(t) = cntR_occ(t) + sum(match2_occ(:)>0);
            accP_occ = accP_occ | match1_occ; 
        end
    end
    
    if opt.w_occ
        cntP_occ(t) = cntP_occ(t) + sum(accP_occ(:));
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
if opt.w_occ
    fprintf(fid,'%10g %10g %10g %10g %10g %10g %10g\n',[thresh cntR sumR cntP sumP, cntR_occ, cntP_occ]');
else
    fprintf(fid,'%10g %10g %10g %10g %10g\n',[thresh cntR sumR cntP sumP]');
end
    
fclose(fid);
end 

