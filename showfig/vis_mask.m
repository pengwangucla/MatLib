function out_img = vis_mask(img, msk, color, alpha)
    assert(size(img,1) == size(msk, 1) && size(img,2) == size(msk, 2), 'mask should have the same size with image');
    assert(alpha >= 0 && alpha < 1, 'alpah should in [0, 1)');
    assert(size(img, 3) == 3 && numel(color) == 3);
    
    msk = logical(msk);
    out_img = reshape(double(img), size(img, 1)*size(img,2), size(img,3));
    for ii=1:size(img, 3)
        out_img(msk(:),ii) = out_img(msk(:), ii) * alpha + (1-alpha)*color(ii);
    end
    out_img = reshape(out_img, size(img, 1), size(img, 2), size(img, 3));
%     for ii = 1:3
%         out_img(msk,ii) = out_img(:,:,ii)*alpha + (1-alpha)*msk*color(ii);
%     end
    out_img = uint8(out_img);
end

