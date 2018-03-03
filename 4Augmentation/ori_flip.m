function img = ori_flip(orient_map, axis, varargin)
% each element of the orient_map is theta the orientation of the pixel 
% set the non valid orientation pixels to -2*pi; 
opt.mask = []; 
opt = CatVarargin(opt, varargin); 

   % assert(size(orient_map,3) == 1); 
   
   img = flip(orient_map, axis); 
   if ~isempty(opt.mask)
       opt.mask = flip(opt.mask, axis); 
       ind = find(opt.mask(:)); 
   else
        ind = find(orient_map(:) ~= -6); 
   end
   
   if isempty(ind); return; end 
   %ind = find(mask_map(:));
   theta = img(ind);
   
   assert(any(theta > pi+eps | theta < -pi-eps));
   img(ind) = -theta; 
end 