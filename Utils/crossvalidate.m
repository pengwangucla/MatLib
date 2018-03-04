function [scorematrix,acc] = crossvalidate(Feat,label,foldnum)
if ~exist('foldnum','var')
    foldnum = 5;
end


% paramters for svm training
lc = 10;
option = ['-q -s 2 -c ' num2str(lc) '-B 1'];

%normalization
%trainkdes = FeatNormalization(FeatTrain);
[feat, ~, ~] = scaletrain(Feat, 'power');

featnum = size(Feat,1);
labelnum = length(unique(label));

scorematrix = size(featnum,labelnum);
acc = zeros(1,length(foldnum));

foldinst = round(featnum/foldnum);

for i = 1:foldnum
    
    trainind = 1:featnum;
    testind = (i-1)*foldinst+1:min(i*foldinst,featnum);
    trainind(testind) = [];
    
    FeatTrain = feat(trainind,:);
    FeatTest = feat(testind,:);
    FeatTrain = sparse(double(FeatTrain));
    FeatTest = sparse(double(FeatTest));
    
    % train using svm
    model = train(label(trainind),FeatTrain,option);
    [~,acc(i),scorematrix(testind,:)] = predict(label(testind),FeatTest,model);
end
