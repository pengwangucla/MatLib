function [imgSet, varargout]= ImgAugmentation(img_origi, varargin);
% produce augmented set of image
% include the augmentation for depth image
DEBUG = 0; 
[height_img, width_img, dim] = size(img_origi);

AugTypes = {'crop', 'flip', 'color', 'rotation', 'blur'};
opt = struct('TrainFlag', 1, 'single',0, 'depth',0, 'sem', 0, ...,
    'orient', 0, 'normal',0, 'blur', 0, 'edge_rot', 0, ..., % whether use edge rotation method 
    'transFlag', true(length(AugTypes),1), ...,
    'crop_size', [228, 304; 196, 261], ...,
    'depth_crop', 'simple', ...,
    'AugProb', [1, 0.7, 0.4, 1, 0], ...,
    'BlurAugType', 'lens', ...,
    'Angels', [-5,5], ...,
    'BlurNum', 5);
opt = CatVarargin(opt, varargin);

if opt.orient && isfield(opt, 'ori_mask')
    opt.ori_img(~opt.ori_mask) = -6;
end

if ~isfield(opt,'crops');
   %  opt.crops = GenRandCrops([height_img, width_img]); 
    opt.crops = GetCropCorner([opt.crop_size]);
end

% sample crops
if opt.AugProb < 1
    cropnum = size(opt.crops,1);
    num = ceil(opt.AugProb(1)*cropnum);
    opt.crops = opt.crops(randperm(cropnum, num),:);
end

crops = [0,0,height_img,width_img; opt.crops]; % add original images
% crops = [opt.crops]; % add original images
Angles = opt.Angels;    
AugNum = [size(crops,1),2,2,length(Angles)+1, opt.BlurNum];
AugNum(~opt.transFlag) = 1;
% assert all the image has the same size 

if opt.TrainFlag
    if opt.single;  single_img = opt.single_img; end % make depth closer as crop into smaller size
    if opt.depth;  depth_img = opt.depth_img; end % make depth closer as crop into smaller size
    if opt.sem; sem_img  = opt.sem_img; end
    if opt.orient; ori_img = opt.ori_img; end
    if opt.normal; normal_img = opt.normal_img; end
    
    depthSet = cell(1, 1);
    semSet = cell(1, 1);
    oriSet = cell(1,1);
    singleSet = cell(1); 
    normalSet = cell(1); 
end

normal_num = size(normal_img,3)/3; 

imgSet = cell(1, 1);
AugImg_counter  = 1;
AugProb = opt.AugProb;

if rand(1) > opt.AugProb(1); AugNum(1) = 1; end 

for icrop = 1:AugNum(1)
    s = height_img/crops(icrop,3);
    h_range = crops(icrop,1)+1:crops(icrop,1)+crops(icrop,3);
    w_range = crops(icrop,2)+1:crops(icrop,2)+crops(icrop,4);
    img_sub = img_origi(h_range, w_range,:);
    
    %  size(img_sub)
    if opt.TrainFlag

        if opt.depth & strcmp(opt.depth_crop, 'geo'); 
            assert(size(depth_img, 3) == 1); 
            if opt.sem; mask = sem_img;
            else
                mask = depth_img == 0;
            end
            temp_sem = mask;
            
            [img_sub, temp_depth, mask, reg_box] = GeoPreserveCropping(img_origi, ...,
                depth_img, mask(:,:,1), crops(icrop,:), opt.crop_camera);
            
            if DEBUG
                subplot_tight(1,3,1); imshow(uint8(img_sub));
                subplot_tight(1,3,2); imshow(temp_depth,[]);
                subplot_tight(1,3,3); imshow(mask);
                pause;
            end
            temp_sem = temp_sem(reg_box(1):reg_box(3), reg_box(2):reg_box(4), :);
            temp_sem(:,:,1) = mask;
            if opt.single; temp_single = single_img(reg_box(1):reg_box(3), reg_box(2):reg_box(4),:); end
            if opt.normal; temp_normal = normal_img(reg_box(1):reg_box(3), reg_box(2):reg_box(4),:); end
            
            if opt.sem; temp_sem  = sem_img(reg_box(1):reg_box(3), reg_box(2):reg_box(4), :); end
            if opt.orient; temp_ori = ori_img(reg_box(1):reg_box(3), reg_box(2):reg_box(4), :); end
            
        else
            
            if opt.depth; temp_depth = depth_img(h_range, w_range,:)/s; end 
            if opt.single; temp_single = single_img(h_range, w_range,:); end
            if opt.normal; temp_normal = normal_img(h_range, w_range,:); end
            %   size(temp_depth)
            if opt.sem; temp_sem  = sem_img(h_range, w_range, :); end
            if opt.orient; temp_ori = ori_img(h_range, w_range, :); end
            
        end % make depth closer as crop into smaller size
    
        
        
    end
    
    Augflip = AugNum(2);
    if rand(1) > AugProb(2); Augflip = 1; end
    
    %% initialization for flip augmentation 
    cur_sub_flip = img_sub;
    if opt.TrainFlag
        if opt.depth; cur_depth_flip = temp_depth; end
        if opt.sem; cur_sem_flip = temp_sem;  end
        if opt.orient; cur_ori_flip = temp_ori; end
        if opt.single; cur_single_flip = temp_single; end
        if opt.normal; cur_normal_flip = temp_normal; end
    end
    
    for iflip = 1:Augflip
        img_sub = cur_sub_flip;
        if opt.TrainFlag
            if opt.depth; temp_depth = cur_depth_flip; end
            if opt.sem; temp_sem = cur_sem_flip; end
            if opt.orient; temp_ori = cur_ori_flip; end
            if opt.single; temp_single = cur_single_flip; end
            if opt.normal; temp_normal = cur_normal_flip; end
        end
        
        if iflip == 2
            img_sub = flip(img_sub, 2);
            if opt.TrainFlag
                if opt.depth; temp_depth = flip(temp_depth, 2); end
                if opt.sem;  temp_sem = flip(temp_sem, 2); end
                if opt.orient; temp_ori = ori_flip(temp_ori, 2); end
                if opt.single; temp_single = flip(temp_single, 2); end
                if opt.normal
                    for in = 1:normal_num
                        c_id = (in-1)*3+1:in*3;
                        temp_normal(:,:,c_id ) = ...,
                            normal_flip(temp_normal(:,:,c_id), 2); 
                    end
                end
            end
        end
        
        Augcolor = AugNum(3);
        if rand(1) > AugProb(3); Augcolor = 1; end
        
        %% initilization for color augmentation
        
        cur_sub_color = img_sub;
        if opt.TrainFlag
            if opt.depth; cur_depth_color = temp_depth; end
            if opt.sem; cur_sem_color = temp_sem;  end
            if opt.orient; cur_ori_color = temp_ori; end
            if opt.single; cur_single_color = temp_single; end
            if opt.normal; cur_normal_color = temp_normal; end
        end
        
        for icolor = 1:Augcolor
            img_sub = cur_sub_color;
            if opt.TrainFlag
                if opt.depth; temp_depth = cur_depth_color; end
                if opt.sem; temp_sem = cur_sem_color; end
                if opt.orient; temp_ori = cur_ori_color; end
                if opt.single; temp_single = cur_single_color; end
                if opt.normal; temp_normal = cur_normal_color; end     
            end
            
            if icolor == 2
                val = rand(3,1)*0.4 + 0.8; 
                for ic = 1:dim 
                    img_sub(:,:,ic) = img_sub(:,:,ic)*val(ic); 
                end
            end
            
            Augrot = AugNum(4);
            if rand(1) > AugProb(4); Augrot = 1; end
            
            %%  initialization for rotation augmentation 
            
            cur_sub_ori = img_sub;
            if opt.TrainFlag
                if opt.depth; cur_depth_ori = temp_depth; end
                if opt.sem; cur_sem_ori = temp_sem;  end
                if opt.orient; cur_ori_ori = temp_ori;  end
                if opt.single; cur_single_ori = temp_single; end
                if opt.normal; cur_normal_ori = temp_normal; end                  
            end
            
            for irotate = 1:Augrot
                img_sub = cur_sub_ori;
                if opt.TrainFlag
                    if opt.depth; temp_depth = cur_depth_ori; end
                    if opt.sem; temp_sem = cur_sem_ori; end
                    if opt.orient; temp_ori = cur_ori_ori; end
                    if opt.single; temp_single = cur_single_ori; end
                    if opt.normal; temp_normal = cur_normal_ori; end                  
                end
                
                if irotate > 1
                    img_sub = Myimrotate(img_sub, Angles(irotate-1));
                    
                    if opt.TrainFlag
                        if opt.depth; 
                            switch opt.depth_crop
                                case 'geo'  % real depth augmentation 
                                    opt_rot.depth_val = 1; 
                                    opt_rot.f = opt.crop_camera(4)/100; 
                                    temp_depth = Myimrotate(temp_depth, Angles(irotate-1), opt_rot); 
                                    opt_rot.depth_val = 0; 
                                case 'simple'
                                    temp_depth = Myimrotate(temp_depth, Angles(irotate-1)); 
                            end
                            
                        end
                        
                        if opt.sem;
                            opt.method = 'nearest';
                            temp_sem = Myimrotate(temp_sem, Angles(irotate-1), opt);
                        end
                        if opt.single;
                            opt_rot.edge_val = opt.edge_rot; 
                            temp_single = Myimrotate(temp_single, Angles(irotate-1), opt_rot);
                            opt_rot.edge_val = 0; 
                        end
                        
                        if opt.normal; 
                            temp_set = cell(1,2); 
                            for in = 1:normal_num
                                c_id =(in-1)*3+1:in*3; 
                                temp_set{in} = ...,
                                    RotateNormalMap(temp_normal(:,:,c_id ),Angles(irotate-1)); 
                            end
                            temp_normal = cat(3, temp_set{:}); 
                        end 
                        
                        if opt.orient;
                            opt.method = 'nearest';
                            temp_ori = RotateOriMap(temp_ori, Angles(irotate-1), opt);
                        end
                        
                    end
                end
                
               %% initilization for blur augmentation 
                cur_sub_blur = img_sub;
                if opt.TrainFlag
                    if opt.depth; cur_depth_blur = temp_depth; end
                    if opt.sem; cur_sem_blur = temp_sem;  end
                    if opt.orient; cur_ori_blur = temp_ori;  end
                    if opt.single; cur_single_blur = temp_single; end
                    if opt.normal; cur_normal_blur = temp_normal; end                      
                end
                Augblur = AugNum(5);
                
                if rand(1) > AugProb(5); Augblur = 1; end
                
                % aug condition 
                if sum(sum(cur_sem_blur(:,:,1)==0))> 0.2*numel(cur_sem_blur); 
                    Augblur_cur = 1;
                else
                    Augblur_cur  = Augblur;
                end
                
                for iblur = 1:Augblur_cur
                    if iblur > 1
                        img_sub = cur_sub_blur;
                        if opt.TrainFlag
                            if opt.depth; temp_depth = cur_depth_blur; end
                            if opt.sem; temp_sem = cur_sem_blur; end
                            if opt.orient; temp_ori = cur_ori_blur; end
                            if opt.single; temp_single = cur_single_blur; end
                            if opt.normal; temp_normal = cur_normal_blur; end                             
                        end
                        
                        % sample lens blur kernel 
                        opt.magnitude = 0.05+rand(1)*0.15;
                        switch opt.BlurAugType
                            case 'lens'
                                opt.FocusPos = round((rand([1,2])*0.8+0.1).*size(cur_depth_blur)); 
                                while cur_sem_blur(opt.FocusPos(1), opt.FocusPos(2)) == 0 
                                    opt.FocusPos = round((rand([1,2])*0.8+0.1).*size(cur_depth_blur));
                                end
                                
                                tmp = img_sub;
                                img_sub = depthFilter_v2(uint8(tmp), temp_depth*255/10, opt)*255;
                                
                                % no need to augment ground truth
                            case 'semantics'
                                [img_sub, non_aug_flag] = semDepthFilter(uint8(img_sub), temp_depth*255/10, ...,
                                    cur_sem_blur(:,:,2), cur_sem_blur(:,:,1), opt);
                                if non_aug_flag
                                    continue;
                                end
                            case 'simple'
                                sigma = ceil(rand(1)*3);
                                h = fspecial('disk',sigma);
                                img_sub = imfilter(img_sub,h,'replicate');
                        end
                        
                        if DEBUG 
                            subplot_tight(2,2,1); imshow(uint8(img_sub)); 
                            subplot_tight(2,2,2); imshow(temp_depth,[]); 
                            subplot_tight(2,2,3); imshow(temp_sem(:,:,1)); 
                            subplot_tight(2,2,4); imagesc(temp_sem(:,:,2)); 
                            pause;
                        end
                    end
                    
                    assert(any(isnan(img_sub(:))) == 0); assert(any(isinf(img_sub(:))) == 0);
                    assert(any(isnan(temp_depth(:))) == 0); assert(any(isinf(temp_depth(:))) == 0);
                    
                    imgSet{AugImg_counter} = img_sub;
                    
                    if opt.TrainFlag
                        if opt.depth; depthSet{AugImg_counter} = temp_depth; end
                        if opt.sem; semSet{AugImg_counter} = temp_sem; end
                        if opt.orient; temp_ori(temp_ori == -6) = 0; oriSet{AugImg_counter} = temp_ori; end
                        if opt.single; singleSet{AugImg_counter} = temp_single; end
                        if opt.normal; normalSet{AugImg_counter}  = temp_normal; end   
                    end
                    
                    AugImg_counter = AugImg_counter + 1;
                end
            end
        end
    end
end

if opt.TrainFlag
    varargout = cell(1,nargout-1); 
    if opt.depth; varargout{1} = depthSet; end
    if opt.sem; varargout{2} = semSet; end
    if opt.orient; varargout{3} = oriSet; end
    if opt.single; varargout{4} = singleSet; end 
    if opt.normal; varargout{5} = normalSet; end 
end
end

function normal = normal_flip(normal, dim)

normal = flip(normal, dim);
normal(:,:,1) = -normal(:,:,1);

end

function normal = RotateNormalMap(normal, angle, varargin)

opt.mask = []; 
opt = CatVarargin(opt, varargin); 

normal = Myimrotate(normal, angle, opt); 
[h,w,d] = size(normal); 
normal = reshape(normal, [h*w, d]); 
rot_ang = (angle*pi/180); 
rot_mat = [cos(rot_ang), -sin(rot_ang ); sin(rot_ang ), cos(rot_ang )]; 
normal(:, 1:2) = (rot_mat*normal(:,1:2)')'; 

normal = reshape(normal, [h, w, d]); 
end


