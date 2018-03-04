function vec = repnum_wp(vec_o, rep_time)
% replicate i th value of vec_o rep_time(i) times and concate to vec;
vec = zeros(sum(rep_time),1);
rep_sum = cumsum(rep_time);
rep_sum = [0,rep_sum];
for ilen = 1:length(vec_o);
    vec(rep_sum(ilen)+1:rep_sum(ilen+1)) = vec_o*ones(rep_time,1);
end