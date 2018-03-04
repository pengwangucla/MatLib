function Save2HDF5(filename, opt, varargin);
opt_default = struct('rewrite', 1, 'shuffle', 0); 
if ~isempty(opt)
    opt = catstruct(opt, opt_default); 
end
names = varargin{end}; 
assert(length(varargin) == length(names) + 1); 
if exist(filename, 'file') & ~opt.rewrite;  
    return;
else
    if exist(filename, 'file');     delete(filename); end 
end 

% must be a four dim blob 
datanum_all = size(varargin{1},4);
for iname = 1:length(names)
    [width, height, mapNum,datanum] = size(varargin{iname}); 
    assert(datanum_all == datanum);
    varname= ['/', names{iname}];
    h5create(filename ,varname, [width, height, mapNum, datanum], ...,
        'Datatype', 'single', 'ChunkSize',[min(100, width), min(100, height), 1, min(datanum, 100)],'Deflate',9);
end
ind = 1:datanum; 
% if opt.shuffle; ind = randperm(datanum,datanum); end 
for iname = 1:length(names)
    data = varargin{iname};
    data = data(:,:,:,ind); 
    varname= ['/', names{iname}]; 
    h5write(filename , varname, data );
end

h5disp(filename); 
end