function deldir(mdir) 
%please add '/' to the dir
filenames = dir(mdir);
if ~strcmp(mdir(end),'/') 
    mdir = [mdir,'/'];
end

if 2 == length(filenames) 
    return;
end
for i = 3:length(filenames)
    delfilename = [mdir,filenames(i).name];
    if exist(delfilename,'file')
        delete(delfilename);
    elseif exist(filenames(i).name,'dir')
        rmdir(delfilename,'s');
    end
end
