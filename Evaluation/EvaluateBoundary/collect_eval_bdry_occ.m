function collect_eval_bdry_occ(pbDir, append, overwrite)


fname = fullfile(pbDir, ['eval_bdry',append,'_e.txt']);
if (length(dir(fname))==1) && ~overwrite
    
    return;
    
else
    
    S = dir(fullfile(pbDir,['*_ev1',append,'.txt']));
     filename = fullfile(pbDir,S(1).name);
    AA = dlmread(filename); % thresh cntR sumR cntP sumP
    thresh = AA(:,1);
    nthresh = numel(thresh);
    cntR_total = zeros(nthresh,1);
    cntR_total_occ = zeros(nthresh,1);
    cntP_total = zeros(nthresh,1);
    cntP_total_occ = zeros(nthresh,1);
    
    % deduce nthresh from .pr files
    for i = 1:length(S)
        filename = fullfile(pbDir,S(i).name);
        AA = dlmread(filename);
        AA_edge = AA(:, 1:5);
        AA_occ = AA(:, [1,6,3,7,5]);
        
        dlmwrite(fullfile(pbDir, [S(i).name(1:end-4), '_e.txt']), AA_edge, ' '); 
        dlmwrite(fullfile(pbDir, [S(i).name(1:end-4), '_o.txt']), AA_occ, ' '); 
        
        cntR = AA(:, 2);
        cntR_occ = AA(:, 6);
        cntP = AA(:, 4);
        cntP_occ = AA(:, 7);
        
        cntR_total = cntR_total + cntR;
        cntR_total_occ = cntR_total_occ + cntR_occ; 
        cntP_total = cntP_total + cntP; 
        cntP_total_occ = cntP_total_occ + cntP_occ;
    end
    collect_eval_bdry(pbDir, [append, '_e']);
    collect_eval_bdry(pbDir, [append, '_o']);
    
    acc_occ = cntP_total_occ./(cntP_total + (cntP_total == 0)); 
    acc_occ_R = cntR_total_occ./(cntR_total + (cntR_total == 0)); 
    dlmwrite(fullfile(pbDir, ['eval',append,'_acc.txt']), [thresh, acc_occ_R, acc_occ], ' '); 
end