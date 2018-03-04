function flag = isemptydir(folder)
folderlist = dir(folder);
folderlist(1:2) = [];
flag = 0;
if isempty(folderlist)
    flag = 1;
end

