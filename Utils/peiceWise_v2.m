
function val = peiceWise(x, opt)
% x :  n x 1 vector 
if size(x, 1) ==1 
    x = x' ; 
end

rangediff = bsxfun(@minus, x, opt.range); 
rangeid  = sum(rangediff >= 0, 2); 
val = zeros(size(x)); 
assigeID = rangeid > 0 & rangeid  < numel(opt.range);
val (rangeid == 0) = opt.rangeVal(1);
val(assigeID ) = opt.rangeVal(rangeid(assigeID)+1);
val (rangeid == numel(opt.range)) = opt.rangeVal(numel(opt.range)+1);

end
