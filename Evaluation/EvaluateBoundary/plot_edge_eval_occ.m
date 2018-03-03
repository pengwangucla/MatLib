function plot_edge_eval_occ(methods, varargin)
opt = struct('dirs', [], 'saveflag', 0, 'savedir', [], 'DataSet', '', 'ylim', [0.6,1]); 
opt = CatVarargin(opt, varargin); 

% open('isoF2.fig');
% hold on
setLinecolorsystem
MethodNames = cell(1, length(methods)); 
for imethod = 1:length(methods)
    if iscell(opt.append); 
        append_all = opt.append{imethod};
    else
        append_all = opt.append; 
    end
    evalDir = opt.dirs{imethod}; 
    if ~exist(fullfile(evalDir,['eval_bdry_thr',append_all,'_e.txt']),'file'),
        fprintf( '%s is not existing \n',  methods{imethod});         continue; 
    end
    prvals = dlmread(fullfile(evalDir,['eval_bdry_thr',append_all,'_e.txt'])); % thresh,r,p,f
    acc_occ = dlmread(fullfile(evalDir, ['eval',append_all,'_acc.txt'])); 
    f_score = prvals(:, 2);  
    p_score = acc_occ(:, 3);  
    [f_score, ind] = sort(f_score, 'ascend');
    if imethod <= length(type_line)
        plot(f_score, p_score(ind), type_line{imethod},'LineWidth',3);    
    else
        icolor = imethod - length(type_line); 
        plot(f_score, p_score(ind), 'Color',colornum(icolor,:), 'LineWidth',3);    
    end
    
    MethodNames{imethod} = sprintf('%s', methods{imethod}); 
    hold on 
end

xh = xlabel('Recall ');
yh = ylabel('Accuracy');
ylim(opt.ylim); 
fontsize = 15; 
set(gca,'XGrid','on');
set(gca,'YGrid','on');
% set(gca, 'GridLineWidth', 3); 
set(xh, 'FontSize', fontsize); 
set(yh, 'FontSize', fontsize); 
set(gca,'FontSize',fontsize);
set(gca, 'LineWidth', 3); 
h = legend(MethodNames);
set(h, 'FontSize', fontsize); 
%set(h, 'FontSize', fontsize, 'position', [0,0,0.2,0.2]); 
legend boxoff 
hold off
if opt.saveflag
    print(gcf,'-depsc2',fullfile(opt.savedir,sprintf('pr_%s.eps',[opt.DataSet, 'all'])));
end

end
