function out = cell2array(in)
out = zeros(1,length(in));
for i = 1:length(in)
     out(i) = str2double(in{i});
end
