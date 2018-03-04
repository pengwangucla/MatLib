function meps2pdf(outputfolder,filename)
exepath = '''C:/CTEX/MiKTeX/miktex/bin/''';
if ~exist(exepath,'dir')
    exepath = ['"','C:\Program Files (x86)\MiKTeX 2.8\miktex\bin\','"'];
    exepath = chslash(exepath,'\');
end

imagename = ['"',outputfolder,filename,'"'];
cmd = [exepath,'epstopdf.exe ', imagename];
system(cmd);
