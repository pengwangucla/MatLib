function cstr_list = ReSortNames(cstr_listin)
% resort the names from matlab function 'dir' by consider the length

strmat = char(cstr_listin);
sortfile=LengthSortStr(strmat);
options.vargin = ' ';
cstr_list = array2cell(sortfile,options);

end
