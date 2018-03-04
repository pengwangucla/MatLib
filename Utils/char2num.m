function i_array = char2num(array)
% change a char string to number 
i_array = zeros(1,length(array));
for i = 1:length(array)
    i_array(i) = str2double(array{i});
    if isnan(i_array(i))
        disp('war');
    end
end
