function out = array2cell(in,options)
% change array to cell array
% in: NxD matrix;
% vargin: [] : keep original; ' ': no space

if ~exist('options','var')
     options.vargin = [];
     options.outputType = 'c';
end
%vargin = options.vargin;
num= length(in);
out = cell(num,1);
for i = 1:num
    switch class(in(1,:))
        % num 2 cell array
        case {'uint32','uint8','double','single'}
            if options.outputType =='c'
                out{i} = num2str(in(i));
            else
                out{i} = int(i);
            end
            
        case {'char'}
            %eliminate the vargin charactor in case char
            if ~isempty(options.vargin)
                s = in(i,:);
                s(s== options.vargin) = [];
                out{i} = s;
            end
    end
end
