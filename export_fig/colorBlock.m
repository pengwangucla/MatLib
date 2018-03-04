function out = colorBlock(colors, varargin); 
% row is num of color
opt = struct('size', [200,400]); 
opt = CatVarargin(opt, varargin); 
dim = size(colors,2); 

if max(colors(:)) > 1;
    colors = double(colors)/255; 
end
out = cell(size(colors,1),1); 
for icolor = 1:size(colors,1)
    img = repmat(colors(icolor,:), [prod(opt.size), 1]); 
    out{icolor} = reshape(img, [opt.size,dim]); 
end