function ShuffleData(DataPath, DataList, dataNames, varargin);
% random shuffle data for better convergence
if nargin == 0
    
    DataPath= '/home/pengwang/Server85/Project/Zhitu/FCNN/caffe-future/examples/GeoSegmentation/'; 
    DataList =  textread([DataPath, 'SUNSegHD5List_train.txt'], '%s'); 
    dataNames  =  {'data','label'}; 
end


if nargin > 3
    LabelList = varargin{4};
    labelNames = varargin{5};
    assert(length(LabelList) == length(DataList));
end

for idata = 1:length(DataList);
    data = hdf5read([DataPath, DataList{idata}],dataNames{1});
    label = hdf5read([DataPath, DataList{idata}],dataNames{2});
    
    datanum = size(data,4);
    ind = randperm(datanum, datanum);
    data = data(:,:,:,ind);
    label = label(:,:,:,ind);
    delete([DataPath, DataList{idata}]);
    
    h5create([DataPath, DataList{idata}],['/', dataNames{1}], size(data), 'Datatype', 'single','ChunkSize',[1, 1, 1, 100],'Deflate',9)
    h5create([DataPath, DataList{idata}],['/', dataNames{2}], size(label), 'Datatype', 'single','ChunkSize',[1, 1, 1, 100],'Deflate',9)
    h5write([DataPath, DataList{idata}], ['/', dataNames{1}], data);
    h5write([DataPath, DataList{idata}], ['/', dataNames{2}], label);
    
    if exist('LabelList', 'var');
        data = hdf5read([DataPath, LabelList{idata}],labelNames{1});
        label = hdf5read([DataPath, LabelList{idata}],labelNames{2});

        data = data(:,:,:,ind); 
        label = label(:,:,:,ind);
        delete([DataPath, LabelList{idata}]);
        h5create([DataPath, LabelList{idata}],['/', labelNames{1}], size(data), 'Datatype', 'single','ChunkSize',[1, 1, 1, 100],'Deflate',9)
        h5create([DataPath, LabelList{idata}],['/', labelNames{2}], size(label), 'Datatype', 'single','ChunkSize',[1, 1, 1, 100],'Deflate',9)
        h5write([DataPath, LabelList{idata}], ['/', labelNames{1}], data);
        h5write([DataPath, LabelList{idata}], ['/', labelNames{2}], label);
    end
end
