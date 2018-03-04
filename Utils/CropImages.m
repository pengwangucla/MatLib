
function varargout = CropImages(bbox, varargin)

if isempty(varargin)
    return; 
end
varargout = cell(1, length(varargin)); 
for iimg = 1:length(varargin)
    varargout{iimg} = varargin{iimg}(bbox(2):bbox(4), bbox(1):bbox(3),:); 
end

end