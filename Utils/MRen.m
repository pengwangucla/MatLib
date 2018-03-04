function MRen(sourcepath, filename, targetname)
cmd = 'ren ';
mpath = sourcepath;
mpath(strfind(mpath,'/')) = '\';
if iscell(filename)
    
else
    sourcefile = ['"', mpath,filename,'"'];
    cmdline = [cmd, sourcefile, ' ', targetname];
end