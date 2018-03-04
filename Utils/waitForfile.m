function waitflag = waitForfile(savepath, filename,pausetime)

while ~exist([savepath filename],'file')
    pause(pausetime);
end
pause(pausetime);

waitflag = 1;

end
