function ind = bwmergeShortEdge(ind_loc, thresh)
% ind_loc: the location of each segment 
% merge the short ones < thresh
num = length(ind_loc); 
len = diff(ind_loc); 
% greedy merge 
ind = ind_loc; 
merge_flag = false(1, num-1); 
for ifrag = 1:length(len);
    if len(ifrag) >= thresh | merge_flag(ifrag)
        continue;
    else
        len_cur = len(ifrag);
        del_id = ifrag+1;  % the indice for current frag on ind_lco
        
        while len_cur < thresh
            if del_id == num 
                ind(ifrag)  = -1; 
                merge_flag(ifrag-1) = 1; 
                break;
            end
            ind(del_id) = -1; 
            len_cur = ind(del_id+1)-ind(ifrag); 
            merge_flag(ifrag) = 1;
            del_id = del_id + 1; 
        end
    end
end

ind(ind == -1) = []; 
len = diff(ind); 
try
assert(all(len >= thresh)); 
catch
    error('len not satisfied');
end
end