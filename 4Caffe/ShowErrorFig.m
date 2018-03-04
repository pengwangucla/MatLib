% Show the error trend of each trained image net work 
% 
function ShowErrorFig(logPath, logfile, lossnames, Set)

if nargin == 0
logPath = '/home/compute/mnt/ilcompf3d0/user/pwang/extern/parsenet/caffe-fcn-pw/examples/DepthPred/eigen/'; 
logPath = '/home/compute/mnt/ilcompf3d0/user/pwang/extern/parsenet/caffe-fcn-pw/examples/DepthPred/parsenet/'; 
logfile = ['log_parsenet_depth.txt']; 
lossnames = {'global_loss', 'fuse_loss'}; 
Set = 'test'; 
end
logfile = [logPath, logfile]; 
fprintf('showing %s \n', logfile); 

if ~exist(logfile, 'file')
    fprintf('%s not exist\n', logfile);
end

fid = fopen(logfile,'r');

line = fgets(fid); 
i = 1; 
while ischar(line)
    line = fgets(fid); 
    i = i + 1;
    if i > 500
        break;
    end
end

color = {'r','b', 'g', 'y', 'k', 'c', 'm'}; 
i = 1;
loss = zeros(1,1, 'single');
loss2 = zeros(1,1,'single');
icounter = ones(length(lossnames),1);
pos = []; 
max_num = 100000; 

switch Set 
    case 'test'
        lossline = 'Test net output'; 
    case 'train'
        lossline = 'Train net output'; 
end

while ischar(line)

     if strfind(line, lossline)
        iline  = 1; line_tmp = cell(1,1); 
        line_tmp{iline} = line; line = fgets(fid);  
        while strfind(line, lossline);  iline = iline + 1; line_tmp{iline} = line; ...,
                line = fgets(fid);  end
        
        for iloss = 1:length(lossnames)
            for iline = 1:length(line_tmp);
                pos = strfind(line_tmp{iline}, [lossnames{iloss}, ' = ']);  
                if ~isempty(pos); line_loss = line_tmp{iline}; break; end
            end
            pos2 = strfind(line_loss, ' ('); 
            if isempty(pos2); pos2 = length(line_loss); end 
            loss(icounter(iloss), iloss) = str2double(line_loss(pos+length([lossnames{iloss}, ...,
                ' = ']):pos2)); 
            icounter(iloss) = icounter(iloss) + 1; 
            pos = []; 
        end
        
     else
         line = fgets(fid);  
     end
     if icounter(1) > max_num
         break;
     end
     
end
fclose(fid);
% loss(loss == 0) = []; 

%%
figure('renderer','zbuffer')
% figure(1); 
for iloss = 1:length(lossnames)
    plot(1:size(loss,1), (loss(1:end,iloss)), [color{iloss}, 'o--'], 'linewidth' ,3); 
    
    search_id = 1:length(loss); 
    [val, id] = min(loss(search_id , iloss)); 
    % legend(lossnames{iloss}); 
    hold on; 
%     if strcmp(Set, 'test')
         fprintf('min val: %.4f', val); 
         fprintf('min iter: %d\n', search_id(id)-1); 
%         plot(id, val, 'kd', 'linewidth' ,5); 
%         legend(lossnames{iloss}); 
%         hold on; 
%     end
    
end

legend(lossnames); 

grid on;
