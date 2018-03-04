function c_array = num2char(array,c_num)
%change a number array into char cell array
c_array = cell(1,length(array));
for i = 1:length(array)
    array(i) = array(i)*10^c_num;
    array(i) = double(round(array(i)))/10^c_num;
    if isnan(array(i))
        disp('warn');
    end
    c_array{i} = num2str(array(i));
    pos = strfind(c_array{i},'.');
    if isempty(pos)
        pos = length(c_array{i})-c_num;
    end
    c_array{i} = c_array{i}(1:pos+c_num);
end
