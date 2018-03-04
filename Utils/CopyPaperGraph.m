addpath('D:\Research\MMatFun');
filepath = 'D:/Research/superpixel/project3/TexDoc/LaTeX/';
filepath = 'D:/Research/Sailency/cvpr2012AuthorKit/latex/';
filepath = 'C:/Users/v-pewa/Dropbox/MySampleCode/ICME/Paper/';
filepath = 'D:\Dropbox\Research\SceneUnderstand\cvpr2013AuthorKit\latex\';
filepath = chslash(filepath,'\');

sourcefile = 'egpaper_for_review_kerneldescriptor.tex';
targetfile = 'SuperpixelSegmentationRename.tex';


patten = 'includegraphics';
patten2 = '\begin{figure';
patten3 = '\end{figure';
spath = 'D:\Research\Sailency\cvpr2012AuthorKit\latex\graph\';
tpath = 'D:\Research\Sailency\cvpr2012AuthorKit\latex\graph2\';
spath = 'C:\Users\Jerry\Dropbox\MySampleCode\ICME\Paper\graph\';
tpath = 'C:\Users\Jerry\Dropbox\MySampleCode\ICME\DemoPaper\graph\';
filepath = '/home/pengwang/Project/Image-Labeling/Document/iccv2015AuthorKit/latex/'; 
spath = [filepath, '/fig/'];
tpath =  [filepath, '/myfigs/']; NewMkdir(tpath); 


sourcefile = 'paper_for_review_part_segmentation_v2_low_res.tex';
fin = fopen([filepath,sourcefile],'r');
%fout = fopen([filepath,targetfile],'w');

%deldir(tpath);
%NewMkdir(tpath);
if fin == -1
    disp('warning');
    return;
end

FigID = 0;
while ~feof(fin)
    str = fgetl(fin);
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
            break;
        end
        pos = strfind(str,patten);
        if ~isempty(pos)
            FigSubID = FigSubID + 1;
            pos1 = strfind(str,'{');
            pos2 = strfind(str,'}');
            pos3 = strfind(str,'/');
            
            if ~isempty(pos3); pos3 = pos3(end); subPath = str(pos1+1:pos3); NewMkdir([tpath, subPath]); 
                tSubPath = [tpath, subPath]; 
            else
                tSubPath = tpath;
            end
            
            filename = str(pos1+1:pos2-1);
            if strfind(computer, 'WIN')
                cmd = 'copy '; 
            else
                cmd = 'cp ';
            end
            if ~exist([spath, filename],'file') | exist([tSubPath,filename],'file')
                disp('no exist || exist');
                continue;
            end
            
            cmdline = [cmd, '"',spath, filename,'"', ' ', '"',[tSubPath], '"',' >null'];
            system(cmdline);
        end
    end
end
fclose(fin);

    

