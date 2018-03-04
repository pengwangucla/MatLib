function wait4file(filename)
    while(~exist(filename,'file'))
        fprintf('%s is not available yet : (\n', filename)
        pause(3);
    end
end
