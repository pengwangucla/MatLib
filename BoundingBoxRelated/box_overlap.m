function overlapmat = box_overlap(results,gt,option)
nres = size(results,1);
ngt = size(gt,1);
intersectbox = zeros(nres,ngt, 4);
intersectbox(:,:,1) =  bsxfun(@max, results(:,1),  gt(:,1)');
intersectbox(:,:,2)=  bsxfun(@max, results(:,2),  gt(:,2)');
intersectbox(:,:,3)=  bsxfun(@min, results(:,3),  gt(:,3)');
intersectbox(:,:,4)=  bsxfun(@min, results(:,4),  gt(:,4)');

switch option
    case 'overlap'
        box = reshape(intersectbox, nres*ngt,4);
        InterAreas = RectArea(box);
        InterAreas(InterAreas < 0) = 0;
        InterAreas = reshape(InterAreas, nres, ngt);
        resArea = RectArea(results);
        resgt = RectArea(gt);
        unionArea = bsxfun(@plus, resArea, resgt');
        overlapmat = InterAreas./(unionArea-InterAreas);
end

end