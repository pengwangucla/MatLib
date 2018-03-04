function ShowMap = visProbMap(Probmap, cmap, type)
if ~exist('type','var'); type = 'prob'; end 
[height,width, labelnum] = size(Probmap);
Probmap = reshape(Probmap,[height*width, labelnum]);
if (size(cmap,1) < labelnum-1);
    cmap = [cmap; zeros(labelnum,3)];
end
if size(cmap,1) ~= labelnum
    cmap = cmap(1:labelnum,:);
end
switch lower(type)
    case 'prob'
        ShowMap = Probmap*cmap;
        ShowMap = reshape(ShowMap, [height, width, 3]);
    case 'max'
        [~,ShowMap] = max(Probmap, [], 2);
        ind = sub2ind(size(Probmap), 1:(height*width), ShowMap');
        Probmap(:) = 0;
        Probmap(ind) = 1;
        ShowMap = Probmap*cmap;
        ShowMap = reshape(ShowMap, [height,width,3]); 
end