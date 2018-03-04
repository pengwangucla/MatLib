function [vec,centerid] = FitInCenter(vec, pattern, pos)
if ~exist('pos','var')
    pos = floor((length(vec) + 1)/2); 
end
assert(length(vec) >= length(pattern))
startid = pos - floor((length(pattern)+1)/2) ;
centerid = (startid+1):(startid+length(pattern));
vec(centerid) = pattern;

end