classdef CaffeTransfromImage
    properties
        
        
    end
    methods
        function obj = CaffeTransfromImage()
            
        end
    end
    
    methods (Static = true)
        function img = transformImg(img, out_sz, image_mean)
            
            img = imresize(img, out_sz);
            img = img(:,:,[3 2 1]); % caffe uses BGR
            img = img - image_mean;
            img = permute(img,[2,1,3]);
            
        end
        
        function depth = transformDepth_norm(depth, out_sz)
            % min max normalization
            ind = depth ~= 0;
            depth = depth*10/255;
            depth_org = depth;
            mindepth = min(depth(ind(:)));
            maxdepth = max(depth(ind(:)));
            
            % judge whether is it a plane
            val = quantile(depth(ind(:)), [0.05,0.95]);
            if diff(val)< 0.05
                depth(ind) = (depth(ind) - mindepth);
            else
                depth(ind) = (depth(ind) - mindepth)./(maxdepth-mindepth+eps);
            end
            depth = imresize(depth,out_sz,'bilinear');
            depth(~ind) = 0;
            
            if sum(depth(:))/prod(out_sz) > 0.9;
                depth = 0;
            end
            
            % if sum(depth(:) < 0) > 0
            %     error('r');
            % end
            
        end
        
        function depth = transformDepth_min(depth, out_sz, segRange)
            % this one is for infer the absolute depth for each segment
            % segbox l, u, r b;
            depth = depth*10/255;
            % change to local correct
            ind = depth ~= 0;

            mindepth = min(depth(ind(:)));
            depth(ind) = depth(ind) - mindepth;

            depth(~ind) = 1;
            depth = imresize(depth, out_sz, 'bilinear');
            depth = log(depth); %allow the change not too small
            
            depth = permute(depth, [2,1]);
        end
        
        function depth = transformDepth_mean(depth, out_sz)
            % this one is for infer the absolute depth for each segment
            % segbox l, u, r b;
            depth = depth*10/255;
            % change to local correct
            ind = depth ~= 0;
            
            % mindepth = min(depth(ind(:)));
            meandepth = mean(depth(ind(:)));
            depth(ind) = depth(ind) - meandepth;
            
            depth(~ind) = 0;
            depth = imresize(depth, out_sz, 'bilinear');
            % depth = log(depth); %allow the change not too small
            
            depth = permute(depth, [2,1]);
        end
        
        function depth = transformDepth(depth,out_sz)
            
            depth = imresize(depth, out_sz, 'nearest');
            depth = depth*10/255;
            depth = depth + 1;
            % depth(depth == 0) = 1;
            depth = log10(depth);
            %        try
            depth = permute(depth, [2,1]);
        end

        function sem = tranformSemantic(sem, out_sz, prunid, labelnum);
            % pruneid which prun the semantic class that is not count in prediction
            if ~isempty(prunid); sem(sem == prunid) = 0; sem(sem > prunid) = sem(sem > prunid)-1; end
            
            sem = imresize(sem,out_sz,'nearest');
            sem = Binarize(sem(:)', labelnum);
            sem = reshape(sem, [out_sz, labelnum]);
            
        end
        
    end
end