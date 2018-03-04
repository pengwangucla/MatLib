function varargout=LengthSortStr(str)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Argment:                str???????????
%        :                ?????sort??
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ch_ascii=1;                               

[N,MAXLEN]=size(str);        
newname=[''];

for i=1:N
        BlackSpace=0;
        while (str(i,MAXLEN-BlackSpace)==' ') 
                BlackSpace=BlackSpace+1;
        end
               
        newstr(i,:)=[repmat(char(ch_ascii),1,BlackSpace), str(i,1:MAXLEN-BlackSpace)];
end
[~,order]=sortrows(newstr);         
sortstr=str(order,:);                                

if nargout<=1
        varargout{1}=sortstr;
elseif nargout==2
        varargout{1}=sortstr;
        varargout{2}=order;
end