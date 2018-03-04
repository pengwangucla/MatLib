
% dir1 = '\\msraim-hpc04\\d$\\users\\v-jiazho\\VideoSuggestionDemo\\images\\Thumbnails\\';
% dir2 = '\\msraim-hpc04\\g$\\user\\v-pewa\\Thumbnail\\';
% 
% ParaSet;
% for i = 1:1%length(queries)
%     for colorid = 1:24
%         fn1 = [dir1 queries{i} num2str(colorid)];
%         if exist(fn1,'dir');
%             fn2 = dir2;
%             if exist(fn2,'dir');
%                 cmd = ['move ' fn1 ' ' fn2 ' >NUL'];
%                 system(cmd);
%             end
%         end
%     end
% end

%%  move dataset
ImageNum = 6000;
date = '0712_';
Image_path = './TestImages/';
%server_path_name = '\\msraim-hpc04\\SAVFiles\\';
sav_path_name = '\\msraim-hpc04\\d$\\users\\v-jiazho\\SAVFiles\\';
%server_image_file = '\\msraim-hpc04\\g$\\user\\v-pewa\\Images\\';
image_path_name = '\\msraim-hpc04\\d$\\users\\v-jiazho\\VideoSuggestionDemo\\images\\Thumbnails\\';
imagetype = '.jpg';
METHOD = {'binary_','soft_','gaussian_','mbinary_','mnobkg_','binaryDouble_','binaryGrow_'};
DATE = '0712_';
METHODID = 1;
Imagecount = 0;

setnum = length(queries);
while setnum >= 2
    disp(queries{setnum});
    NewFolder = [image_path_name,queries{setnum},'98'];
    system(['mkdir ' '"' NewFolder '"', ' >NUL']);
    Test_set = [queries{setnum},'98/'];
    for i = 1:ImageNum
        if mod(i,1000) == 0
            disp(['Image:',num2str(i)]);
        end
        filename = num2str(10000+i);
        if exist([Image_path,Test_set,filename,imagetype],'file')
            image = imread([Image_path,Test_set,filename,imagetype]);
            imwrite(image,[NewFolder,'/',num2str(10000+i),imagetype]);
            Imagecount = Imagecount + 1;
        else
            break;
        end
    end
    Imagecount
    if Imagecount == 0
        rmdir(NewFolder);
    end
    
    setnum = setnum-1;
end
%%





