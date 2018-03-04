
function normval = MNorm(vec,k)
if k == 2
    normval = sqrt(sum(vec.*vec,2));
end 
end