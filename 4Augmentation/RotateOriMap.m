function ori_map = RotateOriMap(ori_map, angle, varargin); 
opt.mask = []; 
opt = CatVarargin(opt, varargin); 

ori_map = Myimrotate(ori_map, angle, opt); 
if isempty(opt.mask)
    ind = find(ori_map ~= -6); 
else
    mask = Myimrotate(opt.mask, angle, opt); 
    ind = find(mask(:)); 
end

theta = ori_map(ind); 
assert(abs(angle) < 180); 

angle = angle*pi/180; 

theta = theta-angle; 

theta(theta > pi) = theta(theta>pi) - 2*pi; 
theta(theta < -pi) = theta(theta<-pi) + 2*pi; 

ori_map(ind) = theta; 

end