function [Temp] = Mload(filename)
if exist(filename,'file')
    Temp = load(filename);
else
    Temp = [];
%    disp('No such a file');
end
