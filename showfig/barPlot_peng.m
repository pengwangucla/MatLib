function barPlot_peng(scaleMat, Testmethod, Criteria, opt); 
opt = struct('saveflag', 0, 'savepath', ''); 

figure;
colortype = [0,1,0; 0,0,1;1,0,0;1,1,0]; 
hmulti = bar(scaleMat);
chi = get(hmulti,'children');

% x(measurement);
% set(hmulti,'Font',10,'linewidth',3);

set(gca,'linewidth',3,'FontSize',18);
set(gca,'fontname','Times','XTickLabel',Criteria);
grid on
ylim([72,80]);

% for i = 1
%     set(chi{i},'FaceColor', colortype(i,:));
% end

h = legend(Testmethod);
set(h,'linewidth',3,'fontname', 'Times', 'fontsize',18); 
h = ylabel('Mean object IOU'); 
set(h, 'fontsize', 25); 

if opt.saveflag
    print('-depsc',[FigPath ,'ScaleInvest',num2str(testset),'.eps']);
end


% rotateticklabel(gca,345,15);