AddPathOcc;

%%
DataSet = 'PASCAL';
DataSet = 'BSDS'; 
switch DataSet
    case 'BSDS'     
        Set = 'test';        SetProjPath;
        ImageList = textread([DataPath, Set, '_occ.txt'], '%s'); omit_id = []; 
    case 'PASCAL'
        Set = 'val';        SetProjPath;
        [ImageList, omit_id, old_id] = GetOccDataList(Set, 0);
end

opt.DataSet = DataSet; 

opt.method = 'hed_pas';

opt.renormalize = 1; 
opt.vis = 1; 
opt.print = 0; 
opt.overwrite = 1; 
opt.visall = 0; 
opt.append = ''; 
opt.validate = 0; 
opt.occ_scale = 1;  % set which scale output for occlusion
opt.w_occ = 1; 
if opt.w_occ; opt.append = '_occ'; end 
opt.scale_id = 0; 
if opt.scale_id ~= 0;
    opt.append = [opt.append, '_', num2str(opt.scale_id)]; 
end

[opt, model_name] = GetMethodConfig(DataSet, opt); 
respath = [occResPath, opt.method_folder, '_occ/', model_name , '/'];
evalPath = [occResPath, opt.method_folder, '_occ/eval_fig/']; NewMkdir(evalPath);
ImageList(omit_id) = []; 

opt.outDir = respath;
opt.resPath = respath;
opt.gtPath = occPath; 
opt.nthresh = 33; 
opt.thinpb = 0; 
opt.renormalize = 1; 

% p = gcp('nocreate');
% if isempty(p),   parpool(4);  end
fprintf('Starting evaluate %s %s, model: %s and %s\n', DataSet, opt.method, model_name, opt.append); 
if opt.validate
    valid_num = 10; 
    ImageList = ImageList(1:valid_num); 
end 

EvaluateBoundary(ImageList, opt);

if opt.vis
    if strfind(opt.append, '_occ'); 
        app_name = opt.append; 
        opt.append = [app_name, '_e'];  plot_eval(opt.outDir, 'r', opt); title('Edge'); 
        % if opt.print,        set(gcf, 'PaperPositionMode', 'auto');        print(['-f' num2str(1)], '-dpng', [evalPath, model_name '.png']);    end
        opt.append = [app_name, '_o'];  plot_eval(opt.outDir, 'b', opt);  title('Occ'); 
        % legend({'edge', 'occ_edge'}); 
        figure; 
        opt.append  = app_name; 
        plot_occ_acc_eval(opt.outDir, 'r',opt); 
    else
        plot_eval(opt.outDir, 'r', opt); 
    end
end


