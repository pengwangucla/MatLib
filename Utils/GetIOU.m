function IOU = GetIOU(mask1, mask2, rect1, rect2);

if nargin < 3
    % kxn1 mask,
    [~,~,d] = size(mask1);
    % kxn2 mask,
    [r,c,d2] = size(mask2);
    mask1 = double(reshape(mask1,[r*c,d]));
    mask2 = double(reshape(mask2,[r*c,d2]));
    % intersect 
    inter = mask1'*mask2;
    union = bsxfun(@plus, sum(mask1,1)', sum(mask2,1))-inter;
    IOU= inter./union;
end

end