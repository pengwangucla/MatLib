global PathAdded
if isempty(PathAdded)
    if ~exist('../src/o2p','dir'); system('ln -sf /mnt/ilcomp19/users/pwang/project/o2p ../src/o2p');    end
    if ~exist('../src/rcnn','dir');system('ln -sf /mnt/ilcomp19/users/pwang/project/rcnn-master ../src/rcnn');    end
    addpath(genpath('../src/'));
    AddProjPath; warning off;
    PathAdded = 1;
end

%%
SetProjPath;
SetTempOpt;
SetVisOpt;
%RangeClass;
SegsTrainTestOpt

if ~exist('Testset','var')
    load([MidResults, 'TrainTestSplit.mat'],'Testset');
    load([MidResults, 'AllTrainExample.mat'], 'ImageFileAll', 'LabelID');
end

%% IOU 
SetType = 'test';
MeasureData = 'NYU';
MeasureType = '';
% Method = 'RCNN';
Method = 'SemOnly'; % only use semantic local segments 
% Method = 'Joint';  %
% Method = 'Local'; %
% Method = 'JCNN'; 
Method = 'Iter'; 
inpaint = 1;
if strcmp(SetType, 'train'); Set = Trainset; else Set = Testset; end 

iterNum = 1; 
if strcmp(Method,'Iter'); iterNum = 3; end 
for Iternum = 1:iterNum
    
% set of results path
% set of RCNN only results 
switch Method
    case 'RCNN'
        PredMapPath = '../../Results/geoPredict/RCNN/'; 
    case 'SemOnly'
        PredMapPath = PredMapPath_sem; 
    case 'JCNN'
        PredMapPath = '../../Results/geoPredict/JCNN/';
end

PredMapPath

resultsPath = cell(1, length(Set));
gtPath = cell(1, length(Set));
imgcounter = 1;

fprintf('Get Results Path\n');
for iimg = Set 
    CountID(iimg,max(Set), 1000);
    
    if isempty(strfind(ImageFileAll{iimg}, MeasureData)); continue; end
    
    pStr = GetLabelPath_v2(ImageFileAll{iimg}); 
    if ~exist(pStr.segPath,'file'); continue; end
    
    pos = strfind(pStr.imgname,'/');
    imgname = pStr.imgname; imgname(pos) = '_';
    switch Method
        case {'RCNN', 'SemOnly'}
            resultsPath{imgcounter} = [PredMapPath, pStr.Data,'/', imgname,'_gc.png']; 
        case 'Joint'
            resultsPath{imgcounter} = [PredMapPath, pStr.Data,'/', imgname,'_gc_joint.png'];
        case 'JCNN'
            resultsPath{imgcounter} = [PredMapPath, pStr.Data,'/', imgname,'.png'];        
        case 'Iter'
            resultsPath{imgcounter} = [PredMapPath, pStr.Data,'/', imgname,'_gc_', num2str(Iternum), '.png']; 
    end

%     if inpaint
%             MapLabel(MapLabel == size(cmap,1)) = 0;
%             MapLabel = InpaintSmallSegs(MapLabel);
%             MapLabel(MapLabel == 0) = size(cmap,1);
%             imwrite(uint8(MapLabel), cmap,  [PredMapPath, pStr.Data,'/', imgname,'_p.png'], 'png');
%     end

    gtPath{imgcounter} = pStr.geoPath;
    imgcounter  = imgcounter  + 1;

end

%%  set of ground truth 
opt_eval = EvaluateIOU('para'); 
opt_eval.saveflag = 1; 
if strcmp(MeasureData,'NYU'); opt_eval.rm_class = 4; end 

opt_eval.cropboarder = 0; opt_eval.padSize = 8; 
opt_eval.savepath = [PredMapPath,'EvalRes'];
switch MeasureData;
    case 'SUN'; opt_eval.categories = opts.classnames(1:opts.geoclass(1));
    case 'NYU'; opt_eval.categories = opts.classnames(opts.geoclass(1)+1:opts.geoclasses);
end
opt_eval.jumpNonExist = 1;
EvaluateIOU(resultsPath, gtPath, opt_eval);

end
