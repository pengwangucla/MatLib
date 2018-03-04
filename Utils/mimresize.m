function img = mimresize(img,max_imsize,min_imsize)
% resize the max length of the image to the predefined max_size and
% min_size

im_h = size(img,1);
im_w = size(img,2);

if max(im_h, im_w) > max_imsize,
    img = imresize(img, max_imsize/max(im_h, im_w), 'bicubic');
end

if min(im_h, im_w) < min_imsize,
    img = imresize(img, min_imsize/min(im_h, im_w), 'bicubic');
end
end
