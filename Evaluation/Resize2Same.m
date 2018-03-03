function varargout = Resize2Same(imgset, varargin); 
opt = struct('sz', [], 'method', 'nearest');
opt = CatVarargin(opt,varargin);

if isempty(opt.sz)
    opt.sz = size(imgset{1}); % resize to the first image size 
end
if length(opt.sz) == 1
    opt.sz = [opt.sz,opt.sz];
end
varargout = cell(length(imgset), 1); 
for i = 1:length(imgset)
    if size(imgset{i},1) ~= opt.sz(1) | size(imgset{i}, 2) ~= opt.sz(2)
        if ischar(opt.method) 
            varargout{i} = imresize(imgset{i}, opt.sz, opt.method);
        else
            varargout{i} = imresize(imgset{i},  opt.sz, opt.method{i});
        end
    else
        varargout{i} = imgset{i}; 
    end
end

end