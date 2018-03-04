addpath(genpath('D:\Research\MMatFun'));
clear all;
%function Rankfigure(inpath, imagenames, Rnumber, Cnumber, outpath)
% a pre comment that all the images are same size 
inpath = 'D:/Research/superpixel/project3/iccv2011AuthorKit/latex/graph/';
outpath = 'D:/Research/superpixel/project3/iccv2011AuthorKit/latex/graph/CominedImage/';
allfoldernames = dir(inpath);
FigID = 3;
count = 0;
FigFolder = [inpath,'Fig',num2str(FigID),'/'];
imagenames = dir(FigFolder);
delid = false(1,length(imagenames));
for i = 3:length(imagenames)
    if isdir([FigFolder,imagenames(i).name])
        delid(i) = 1;
    end
end
imagenames(delid) = [];
imgtypeSet  = {'jpg','png','bmp','tiff'};
imagetype = imagenames(end).name(end-2:end);

TotalNum = length(imagenames)-2;

Rnumber = 1;
Cnumber = TotalNum/Rnumber;
space = 10;
imgid = 0;
for i = 3:length(imagenames)
    if ismember(imagetype,imgtypeSet)
        img = imread([FigFolder,imagenames(i).name]);
    elseif strcmp(imagetype,'pdf');
        filename = [FigFolder,imagenames(i).name];
        outname = [FigFolder,imagenames(i).name(1:end-4),'.png'];
        cmd = ['-dNOPAUSE -dBATCH -sDEVICE=pngalpha -r300 -sOutputFile=', outname,' ',filename];
        ghostscript(cmd);
        img = imread([FigFolder,outname]);
    end
    if ~isempty(img)
        imgid = imgid + 1;
         imgset{imgid} = img;
    end
end
height = 361;
width = 481;
dim = 3;
[height,width,dim] = size(imgset{1});
%%

BigImage = 255*ones(height*Rnumber+space*(Rnumber-1),width*Cnumber+space*(Cnumber-1),dim);
for i = 1:Rnumber
    srow = (height+space)*(i-1)+1;
    erow = height*i+space*(i-1);
    for j = 1:Cnumber
        scol = (width+space)*(j-1)+1;
        ecol = width*j+space*(j-1);
        img =  imgset{Cnumber*(i-1)+j};
        img = imresize(img,[height,width]);
        BigImage(srow:erow,scol:ecol,:) = img;
    end
end
BigImage = uint8(BigImage);
imshow(BigImage);
print('-painters','-depsc',[outpath,'Fig',num2str(FigID),'.eps']);
meps2pdf(outpath,['Fig',num2str(FigID),'.eps']);
%% simplely convert 
% FigID = 11;
% subfolder = 'MBigImage/';
% meps2pdf([outpath],['Fig',num2str(FigID),'.eps']);