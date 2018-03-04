function ShowRetrievalRes(query, Afinity, dictionary, varargin)
% show retrival from the database dictionary
% Afinity: ndic x k value show the Afinity to each dictionary 
% query: cell of images 
% dictionary: cell of dictionary images,  dicNum x dicContent Image num 

opt = struct('topk', size(dictionary,1), 'fmt', [6, 5], 'saveflag', 0, 'savePath', './temp/'); % maximum top 10
if ~isempty(varargin); opt = catstruct(varargin{1}, opt); end 
assert(opt.topk <= size(dictionary,1)); 
if size(Afinity,2) ~= length(query)
    Afinity = Afinity'; 
end 

[dicnum, querynum] = size(Afinity);
[dicnum, dicContentNum] = size(dictionary);
[topval, topid] = GetTopK(Afinity, 1, opt.topk, 'descend');
opt.fmt(1) = 2+ceil(opt.topk/opt.fmt(2))*dicContentNum; 

 fmt = opt.fmt;
for iquery = 1:querynum 
    imgind = genplotind([1:2], [1:2], fmt);
    subplot_tight(fmt(1), fmt(2), imgind); imshow(query{iquery}); freezeColors;
    if isfield(opt, 'AddRes'); 
        for ires = 1:length(opt.AddRes)
            row = floor((ires-1)/(fmt(2)-2))+1;   
            col = 2+mod(ires-1, fmt(2)-2)+1; 
            imgind = genplotind(row, col, fmt);
            subplot_tight(fmt(1), fmt(2), imgind); imshow(opt.AddRes{ires}); freezeColors; 
        end
    end
    
    for iretrieval = 1:opt.topk
        col = mod(iretrieval-1, fmt(2))+1;
        row_start = 2 + (floor((iretrieval-1)/fmt(2)))*dicContentNum+1;
        for idicContent = 1:dicContentNum
            row = row_start + idicContent-1;
            imgind = genplotind(row,col, fmt);
            if ~isfield(opt,'diccmap');
                subplot_tight(fmt(1), fmt(2), imgind); imshow(dictionary{topid(iretrieval), idicContent}); 
            else
                subplot_tight(fmt(1), fmt(2), imgind); imshow(dictionary{topid(iretrieval), idicContent}, opt.diccmap); freezeColors;
            end
            % title(sprintf( 'Afinity, %.4f', topval(iretrieval)));
        end
    end
    
    if querynum > 1
        pause;
    end
    if opt.saveflag
        save(gca, [opt.savePath, '_', num2str(iquery), '.png'], 'png');
    end
end

end