function imgs = imsetresize(imgs,varargin)
% resize a image set 
if iscell(imgs)
    for iimg = 1:length(imgs)        
        imgs{iimg} = imresize(imgs{iimg},varargin{:});
    end
else
    imgs = imresize(imgs,varargin{:});
end
