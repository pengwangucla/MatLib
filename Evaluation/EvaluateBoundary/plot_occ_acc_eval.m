function plot_occ_acc_eval(evalDir, c, varargin)
opt.append = ''; 
opt.recall_thresh = 0.5; 
opt = CatVarargin(opt, varargin); 

if exist(fullfile(evalDir,['eval_occ_acc.txt']),'file'),
    
    prvals = dlmread(fullfile(evalDir,['eval_bdry_thr',opt.append, '_e','.txt'])); % thresh,r,p,f
    acc_occ = dlmread(fullfile(evalDir, ['eval',opt.append,'_acc.txt'])); 
    f_score = prvals(:, 2);  
    p_score = acc_occ(:, 3); 
    %valid_thresh = prvals(:,2) > opt.recall_thresh; 
    
%     f_score = f_score(valid_thresh); 
%     p_score = p_score(valid_thresh); 

    [f_score, ind] = sort(f_score, 'ascend');
    plot(f_score, p_score(ind), c,'LineWidth',3);
    set(gca,'XGrid','on');
    set(gca,'YGrid','on');
    xlabel('Recall ');
    ylabel('Accuracy');
    title('Occlusion accuracy Curve');
end

end