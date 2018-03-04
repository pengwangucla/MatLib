function namelist = ReadFileNames(file, append)
if ~exist('append','var')
    append = ''; 
end


fid = fopen(file, 'r');

line = fgets(fid);
i = 1;
namelist = cell(1,1);
while ischar(line)
    if strcmp(line(1), '%'); line = fgets(fid); continue; end 
    namelist{i} = [line(1:end-1), append];
    line = fgets(fid);
    i = i + 1; 
end
fclose(fid); 

end