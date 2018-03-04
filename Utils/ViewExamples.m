function filenames = ViewExamples(DatasetStru,prestru);
% assume the data is arranged as the order of datasetstru
datanum = 0;
for iclass = 1:length(DatasetStru)
    datanum = datanum + length(DatasetStru(iclass).ObjInstance{1}.instImglist);
end

predictlabel = prestru.predictlabel;
gtlabel = prestru.gtlabel;
testind = prestru.Testind;% the ind in all the data 

if length(predictlabel) ~= length(gtlabel)
    error('predictlabel and gtlabel needs to be the same len');
end
for iclass = 1:length(DatasetStru)
    datarange = [datacount + 1,datacount + length(DatasetStru(iclass).ObjInstance{1}.instImglist)];
    ind = find(testind >= datarange(1) & testind < datarange <= datarange(2));
    misind = gtlabel(ind) ~= predictlabel(ind); 
    filenames{iclass} = DatasetStru(iclass).ObjInstance{1}.instImglist(misind);
    misid{iclass} = predictlabel(ind(misind));
end

if verbose
    for iclass = 1:length(DatasetStru) % each class we plot a graph
        if isempty(misid{iclass})
            continue;
        end
        misclass = unique(misid{iclass});
        for imisclass = 1:length(misclass)
            classid = misclass(imisclass);
            ind = find(misid{iclass} == classid);
            for iimg = 1:length(ind)
                catoStru = DatasetStru(classid);
                img = imread([catoStru.ObjInstance{1}.instPath,filename]);
                subplot(iclass,iimg,img)       
                title(catoStru.ObjCatoName);
            end
        end
        print(gca,'-depsc','-painters',[prestru.savepath,DatasetStru(iclass).ObjCatoName,'.eps']);
    end
end
end