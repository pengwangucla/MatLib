function obj = confMatPlot_peng(confMat,opt)

% check the results, rows are precision and columns are recall 

if ischar(confMat) && strcmpi(confMat, 'defaultOpt')
    obj.fontSize=15;
    obj.numfontSize = 15;
    obj.format='8.2f';
    obj.extent = 0; %
    obj.mode = 'percentage';
    obj.height = 300;
    obj.width = 600;
    obj.maxvalue = 1;
	return
end

confMat = double(confMat);
[m, n]=size(confMat);
% 
prob = confMat./(sum(confMat,2)*ones(1, size(confMat,1)));

confimg = imresize(prob*opt.maxvalue ,[opt.height,opt.width],'nearest');

imshow(confimg+1-opt.maxvalue);
%imshow(opt.maxvalue -confimg);
%%  plot the accuracy
diagCount=sum(diag(confMat));
allCount=sum(sum(confMat));
overall = diagCount/allCount;
newProb = round(prob*100000000)/1000000;
newOverall = round(overall*100000000)/1000000;

% Place the text in the correct locations
opt.format = '8.1f';
plotcontent(newProb,opt)

%% plot the text 
vspace = opt.height/m;
hspace = opt.width/n;

% plot the up text
opt.colUpLabel = opt.className;
for j=1:n
    obj.colUpLabel(j)=text((j-.5)*hspace, -5, opt.colUpLabel{j}, ...
        'HorizontalAlignment', 'left', ...
        'rot', 45, ...
        'Color', 'k', ...
        'FontSize', opt.fontSize);
end
% plot the left text
opt.rowLeftLabel = opt.className;
for i = 1:m
    obj.rowLeftLabel(i)=text(-70, (i-.5)*vspace, opt.rowLeftLabel{i}, ...
        'HorizontalAlignment', 'left', ...
        'Color', 'k', ...
        'FontSize', opt.fontSize);
end 

opt.gridColor='k';
% set(gca,'Box','on',...
%         'Visible', 'off', ...
%         'xTickLabel', [], ...
%         'yTickLabel', [], ...
%         'GridLineStyle', ':', ...
%         'LineWidth', 2);
    
end 

function plotcontent(a,opt)
[m,n] = size(a);
vspace = opt.height/m;
hspace = opt.width/n;

for i=1:m		% Index over number of rows
	for j=1:n	% Index over number of columns
		theStr=a(i,j);
		if isnumeric(a(i,j))
			theStr=num2str(a(i,j), ['%', opt.format]);
        end
        if i==j
            obj.element(i,j)=text((j-.5)*hspace, (i-.5)*vspace, theStr, ...
                'HorizontalAlignment', 'center', ...
                'Color', [0,0,0], ...
                'FontSize', opt.numfontSize);
        else
            obj.element(i,j)=text((j-.5)*hspace, (i-.5)*vspace, theStr, ...
                'HorizontalAlignment', 'center', ...
                'Color', [0,0,0], ...
                'FontSize', opt.numfontSize);
        end
	end
end

end
