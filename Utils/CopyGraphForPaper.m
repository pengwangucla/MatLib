addpath('D:\Research\MMatFun');
filepath = 'D:/Research/superpixel/project3/TexDoc/LaTeX/';
filepath = 'C:/Users/v-pewa/Dropbox/MySampleCode/ICME/Paper/';
filepath = 'E:/latex/';


sourcefile = 'egpaper_for_review_kerneldescriptor.tex';
%targetfile = 'SuperpixelSegmentationRename.tex';
patten = 'includegraphics';
patten2 = '\begin{figure';
patten3 = '\end{figure';
spath = [filepath, '\figs\'];
tpath =  [filepath, '\myfigs\'];


fin = fopen([filepath,sourcefile],'r');
%fout = fopen([filepath,targetfile],'w');

%deldir(tpath);
if fin == -1
    disp('warning');
    return;
end

FigID = 0;
while ~feof(fin)
    str = fgetl(fin);
%    fprintf(fout,'%s\n',str);
    pos = strfind(str,patten2);
    if ~isempty(pos)
        FigID = FigID+1;
    else
        continue;
    end
    FigSubID = 0;
    while ~feof(fin)
        str = fgetl(fin);
        pos = strfind(str,patten3);
        if ~isempty(pos)
            %fprintf(fout,'%s\n',str);
            break;
        end
        pos = strfind(str,patten);
        if ~isempty(pos)
            FigSubID = FigSubID + 1;
            pos1 = strfind(str,'{');
            pos2 = strfind(str,'}');
            %pos3 = strfind(str,'_');
            
            filename = str(pos1+1:pos2-1);
            foldername = ['Fig',num2str(FigID)];
            ntpath = [tpath,foldername];
            NewMkdir(ntpath);
            ntpath = [ntpath,'\'];
            cmd = 'copy ';
            cmdline = [cmd, '"',spath, filename,'"', ' ', '"',[tpath,foldername], '"', '>null'];

            cmd = 'ren ';
            NewName =  ['Fig',num2str(FigID),'_',num2str(FigSubID),'_',filename];
            cmdline2 = [cmd, '"',ntpath, filename,'"', ' ', ...,
               NewName, '>null'];
            if ~exist([tpath,NewName],'file')
                system(cmdline); %copy
              % system(cmdline2); %rename
            end
            
        %    Newstr = [str(1:pos1),NewName,str(pos2:end)];
        %    fprintf(fout,'%s\n',Newstr);
        else
       %     fprintf(fout,'%s\n',str);
        end
    end
end
fclose(fin);
%fclose(fout);

return;
%%
PathSubmit = 'D:\Research\superpixel\project3\TexDoc\LaTeX\Submit\';
filename = dir([PathSubmit,'*.bib']);
FileID = 10;
for i = 1:length(filename)
    cmd = 'ren ';
    pos = strfind(filename(i).name,'_');
    if ~isempty(pos)
        bibname = filename(i).name(pos(end)+1:end);
    else
        bibname = filename(i).name;
    end
    newname = ['Re_',num2str(FileID),'_',bibname];
    cmdline = [cmd, PathSubmit,filename(i).name,' ',newname];
    system(cmdline);
    FileID = FileID + 1;
end

    

