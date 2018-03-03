function plot_edge_eval(methods, varargin); 
opt = struct('dirs', [], 'saveflag', 0, 'savedir', [], 'fontsize', 20, 'location', 'northeast', ...,
    'withHNode', 1); 
opt = CatVarargin(opt, varargin); 
figfile = 'isoF2.fig'; 

open(figfile);
if opt.withHNode
    %figfile = 'isoF.fig'; 
    if(1), hn=plot(0.7235,0.9014,'o','MarkerSize',8,'Color',[0 .5 0],...
    'MarkerFaceColor',[0 .5 0],'MarkerEdgeColor',[0 .5 0]); end
else
    
end 

hold on

setLinecolorsystem

LegendNames = cell(1, length(methods)); 
h = zeros(1,  length(methods)); 
for imethod = 1:length(methods) 
    evalDir = opt.dirs{imethod}; 
    if ~exist(fullfile(evalDir,['eval_bdry_thr',opt.append ,'.txt']),'file'),
        fprintf( '%s is not existing \n',  methods{imethod}); 
        continue; 
    end
    
    prvals = dlmread(fullfile(evalDir,['eval_bdry_thr', opt.append ,'.txt'])); % thresh,r,p,f
    f=find(prvals(:,2)>=0.01);
    prvals = prvals(f,:);
    
    evalRes = dlmread(fullfile(evalDir,['eval_bdry', opt.append ,'.txt']));
    %if size(prvals,1)>1,
    h(imethod) = plot(prvals(1:end,2),prvals(1:end,3), type_line{imethod},'LineWidth',3);
%     else
%         plot(evalRes(2),evalRes(3),'o','MarkerFaceColor',cmap(imethod, :), ...,
%             'MarkerEdgeColor',cmap(imethod, :),'MarkerSize',8);
%     end
    LegendNames{imethod}=sprintf('[F=%4.2f] %s', evalRes(4), methods{imethod});
    hold on
end
% xh = xlabel('Recall ');
% yh = ylabel('Precision');

LegendNames(cellfun(@isempty, LegendNames)) = []; 
if opt.withHNode; h = [hn, h];   LegendNames = [{'[F=.80] Human'},LegendNames]; end 
fontsize_legend = opt.fontsize; 
fontsize_other = 20; 
h_leg = legend(h, LegendNames, 'Location', opt.location);
xh = xlabel('Recall ');
yh = ylabel('Precision');
set(xh, 'FontSize', fontsize_other); 
set(yh, 'FontSize', fontsize_other); 
set(gca,'FontSize',fontsize_other);
set(h_leg, 'FontSize', fontsize_legend); 
legend boxoff 

if opt.saveflag
    print(gcf,'-depsc2',fullfile(opt.savedir,sprintf('pr_%s.eps',[opt.DataSet, 'all_edge'])));
end

end
