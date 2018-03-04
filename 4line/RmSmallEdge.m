function bmap = RmSmallEdge(bmap, thresh)
max_range = 8; 
CC = bwconncomp(bmap,max_range); 
for icc = 1:length(CC.PixelIdxList)
    if length(CC.PixelIdxList{icc}) < thresh;
        bmap(CC.PixelIdxList{icc}) = 0; 
        continue; 
    end 
end