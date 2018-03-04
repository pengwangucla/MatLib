function Mcopy(Source, filename, Target, choice)

TmpStr = changeSlash({Source,filename,Target});
Source = TmpStr{1};
filename = TmpStr{2};
Target = TmpStr{3};

if exist([Source, filename],'dir')
    cmd = 'xcopy ';
    ftype = 'dir';
else
    cmd = 'copy ';
    ftype = 'file';
end
cmdline = [cmd,'"', [Source, filename],'"', ' ','"',Target,'"',' >NULL'];

if exist('choice','var')&&strcmp(choice,'o')
    system(cmdline);
else
    if ~exist([Target,filename],ftype)
        system(cmdline);
    end
end

end
function NStr = changeSlash(Str)
if iscell(Str)
    NStr = cell(1,length(Str));
    for i = 1:length(Str)
        pos = strfind(Str{i},'/');
        tempstr = Str{i};
        tempstr(pos) = '\';
        NStr{i} = tempstr;
    end
else
    pos = strfind(Str,'/');
    NStr(pos) = '\';
end
end