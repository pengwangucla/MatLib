function feat_in = FeatNormalization(feat_in,opt)
% feat_in is a nxd matrix: n feat number, d feat dimention
if ~exist('opt','var')
    opt.mode = 2;
end

if opt.mode == 0
    return;
end

if isstruct(feat_in)
    %if the feat_in is the defined struct. 
    
    %trainkdes = FeatNormalization(FeatTrain);
    [feat, ~, ~] = scaletrain(feat_in.FeatTrain', 'power'); %
    feat_in.FeatTrain = feat';
    
else
    [~,d] = size(feat_in);
    feat_norm = mnorm(feat_in,opt);
    if opt.mode < 3
        feat_in = feat_in./repmat(feat_norm+eps,[1,d]);
    elseif opt.mode == 3
        feat_in = feat_norm;
    elseif opt.mode == 5
        feat_in = (feat_in-repmat(feat_norm(1),[1,d]))./repmat(feat_norm(2)-feat_norm(1)+eps, [1,d]); 
    end
end
end

function feat_norm = mnorm(feat_in,opt)

switch opt.mode
    case 1
        feat_norm = sum(abs(feat_in),2);
    case 2 
        feat_norm = sqrt(sum(feat_in.^2,2));
    case 3 
        feat_norm = scaletrain(feat_in', 'power'); %
    case 4 % rescale
        if ~isfield(opt,'scale')
            opt.scale = 100;
        end
        feat_norm = repmat(opt.scale,[size(feat_in,1),1]);
    case 5 % min max 
        feat_norm(1) = min(feat_in, [], 1);
        feat_norm(2) = max(feat_in, [], 1);
end

end


