function SaveList2File(imglist, fiename, range); 
if ~exist('range','var'); 
    range = [1, 0]; 
end

fid = fopen(fiename, 'w'); 

for iimg = 1:length(imglist); 
    fprintf(fid, '%s\n', imglist{iimg}(range(1):end-range(2))); 
end
fclose(fid); 