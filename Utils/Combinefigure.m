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

imagetype = imagenames(end).name(end-2:end);
getfilenames;
%% load images the order of image is the same with the output figure 
imgtypeSet  = {'jpg','png','bmp','tiff'};
TotalNum = length(imagenames)-2;
Cnumber = TotalNum/Rnumber;
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
%%  output the single figure 
Rnumber = 1;
option.imsize = [height,width]; % the size of each showing image 
option.space = 10; % the space between different images; 
BigImage = GenBigImg(imgset,Rnumber,option);
BigImage = uint8(BigImage);
imshow(BigImage);
print('-painters','-depsc',[outpath,'Fig',num2str(FigID),'.eps']);
meps2pdf(outpath,['Fig',num2str(FigID),'.eps']);

%% simplely convert 
% FigID = 11;
% subfolder = 'MBigImage/';
% meps2pdf([outpath],['Fig',num2str(FigID),'.eps']);