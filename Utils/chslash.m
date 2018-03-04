function str_out = chslash(str_in,mode)
if ~exist('mode','var')
    mode = '\';
end

str_out = str_in;
pos = strfind(str_in,mode);

if ~isempty(pos)
    switch mode
        case '/'
            str_out(pos) = '\';
        case '\'
            str_out(pos) = '/';
    end
    
end
       