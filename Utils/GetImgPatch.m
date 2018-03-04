function [patches, patchpixid] = GetImgPatch(img, centerid, patchsz)
% center:  height position + width position [r,c]
% patchsz: height + width 
% Don't let cetner id increase 
if numel(patchsz) == 1
    patchsz = [patchsz, patchsz];
end
[h2,w2,dim] = size(img);
centernum = size(centerid,1);
sz(1) = floor((patchsz(1)+1)/2);
sz(2) = floor((patchsz(2)+1)/2);

PatchHeightRange = -sz(1)+1:-sz(1)+patchsz(1);
PatchWidthRange = -sz(2)+1:-sz(2)+patchsz(2);
[PatchINDx, PatchINDy]  = meshgrid(PatchWidthRange, PatchHeightRange);
% each row is a patch indexed by their x y position
patchesy = min(max(1, repmat(centerid(:,1),[1,prod(patchsz)]) + ...,
    repmat(PatchINDy(:)', [centernum,1])), h2);
patchesx = min(max(1,repmat(centerid(:,2),[1,prod(patchsz)]) + ...,
    repmat(PatchINDx(:)', [centernum,1])), w2);
patchpixid = sub2ind([h2,w2], patchesy(:), patchesx(:));

for idim = 1:dim
    tmp = single(img(:,:,idim));
    patches = tmp(patchpixid);
    patches = reshape(patches, [centernum, patchsz]); 
end

patchpixid = reshape(patchpixid,[centernum, patchsz]);

end

