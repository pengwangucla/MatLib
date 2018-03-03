function crops = GenRandCrops(imgSize, varargin); % height, width
% return l t
opt = struct('crops_num', 1, 'scale', 2);
opt = CatVarargin(opt, varargin);
crops = zeros(opt.crop_num, 4);

for i = 1:opt.crop_num
    s = rand(1)*opt.scale + 1.1;
    
    sz_n = floor(imgSize/s);
    corner = round(max(imgSize-sz_n-4,5));
    
    crops(i,:) = [randperm(corner(1), 1), randperm(corner(2), 1), sz_n];
    assert(crops(i,1) + crops(i,3) <= imgSize(1) & crops(i, 2) + crops(i, 4) < imgSize(2)); 
end