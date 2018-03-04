
function SaveListFile(filename, relpath, filelist)
fid = fopen(filename, 'w');
for i = 1:length(filelist)
    if i == length(filelist);
        fprintf(fid, '%s', [relpath, filelist{i}]);
    else
        fprintf(fid, '%s\n', [relpath, filelist{i}]);
    end
end
fclose(fid);
end