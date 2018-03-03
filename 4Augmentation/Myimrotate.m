function [img, varargout] = Myimrotate(img, angle, varargin)
opt  = struct('hm',8,'wm',6, 'method', 'bilinear', 'depth_val', 0, 'edge_val', 0, 'f', 5.8);
opt = CatVarargin(opt, varargin); 

[height,width,~] = size(img);
img = imrotate(img, angle, opt.method);
[angle, phase] = getCropAngle(angle); 

if phase == 2 | phase == 4
    temp = height; 
    height = width; 
    width = temp;
end
% [h_r, w_r, ~] = size(img); 
theta = angle*pi/180; 
h_r = round(height*cos(theta) + width*sin(theta)); 
w_r = round(height*sin(theta) + width*cos(theta)); 
img = imresize(img, [h_r, w_r], opt.method); 

[crop_h, crop_w] = getCropPadding(angle, [height, width], [h_r, w_r]); 
[crop_h_flip, crop_w_flip] = getCropPadding(90-angle, [width, height], [h_r, w_r]); 
crop_h = max(crop_h, crop_h_flip);
crop_w = max(crop_w, crop_w_flip);
img = cropPadding(img, ceil([crop_h, crop_w]));
% if this is depth we need to rescale the depth since we cropped the image
if opt.depth_val
    [h,w,~] = size(img); 
    scale = height/h; 
    %d = min(img(img ~= 0))+0.01;
    img = img/scale; % in meters, can not be negative value 
end

if opt.edge_val
    img(:,:,1) = edge_nms(img(:,:,1), 0);
end

if nargout > 1
    [~, pos] = myImrotate(img, angle);
    pos = cropPadding(pos, ceil([height*ratio + opt.hm, width*ratio +opt.wm]));
    varargout{1} = pos;   
end
end

function [angle, phase] = getCropAngle(angle)
assert(angle < 360); 
phase = floor(abs(angle)/90)+1; 
angle = mod(abs(angle), 90); 
if angle == 0
    return; 
end    
end

function [h,w] = getCropPadding(angle, sz, sz_r); 

angle = (angle/90)*pi/2; 
angle2 = atan(sz_r(1)/sz_r(2)); 
angle3 = pi-(angle+angle2); 
b = sz(2)*cos(angle); 
a = sin(angle)*b/sin(angle3); 
w = a*cos(angle2); 
h = a*sin(angle2); 

end