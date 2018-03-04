function saveImg2bin(filenames); 

I = I(:,:,[3 2 1]); % caffe uses BGR
I = permute(I,[2,1,3]);

fid_data = fopen(data_file, 'w');
fwrite(fid_data, I, 'uint8');
fclose(fid);

end 