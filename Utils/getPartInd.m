function ind = getPartInd(totalNum, partnum, ipart)
% this function is specific for manually multi core 
% chose which part to run for total Num

partRange = ceil(totalNum/partnum);
ind = 1+ partRange*(ipart-1): min(partRange*ipart,totalNum);

end