function [ele, indices] = FindElement(array, cond, sub_ele); 

if ~exist('cond', 'var') 
    cond = 'maxlen'; 
end

if isempty(array)
    ele = 0; indices = []; 
    return;
end

if nargin < 3
    [array_sort, ~] = sort(array, 'ascend'); 
    id = unique(array_sort); 
else
    sub_ele = unique(sub_ele); 
    id = sort(sub_ele, 'ascend'); 
end

freq = histc(array, id);

switch cond
    case 'maxlen'
        % find the maximum happened element
        [~,max_id] = max(freq); 
        ele = id(max_id); 
        indices = find(array == ele); 
    case 'minlen'
        [~,min_id] = min(freq); 
        ele = id(min_id); 
        indices = find(array == ele); 
end
