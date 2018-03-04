%% 
S = 255;
while S > 1
    H = [1:360];
    V = [1:255]';
    
    [H,V]=meshgrid(H,V);
    
    height = 255;
    width = 360;
    temp = zeros(255, 360, 3);
    hsv_value = zeros(height,width,3);
    
    hsv_value(:,:,1) = H/360;
    hsv_value(:,:,2) = S/255;
    hsv_value(:,:,3) = V/255;
    
    rgb_value = hsv2rgb(hsv_value);
    
    for i = 1:3
        subplot(1,4,i);
        imshow(rgb_value(:,:,i),[]);
    end
    subplot(1,4,4);
     imshow(rgb_value,[]);
      axis on;
    pause;
    close gcf
    S =S-10
end
