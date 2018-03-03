function [new_edge, new_occ, varargout] = Shrink2Edge(edge_pred, ...,
    edge_occ, thresh, vis, method); 

% remove the small noisy edges and get the right theta 
    if ~exist('vis','var'); vis = 1; end 
    if ~exist('method','var'); method = 'pix'; end 
    
    assert(all(size(edge_pred(:,:,1)) - size(edge_occ(:,:,1)) == 0) ); 
   
    thin_edge = edge_nms(edge_pred, thresh); 
    
    new_occ = zeros(size(thin_edge), 'single'); 
    sim_score = new_occ; 
    
    % new_edge = new_occ; 
    [frags, new_edge] = GetOrderFrags(thin_edge,5);
    new_edge = single(new_edge); 
    if strcmp(method, 'bin'); 
        [edge_occ_val, edge_occ_id] = max(edge_occ, [], 3); 
        edge_occ_id = edge_occ_id - 1; 
    end
    
    for ifrag = 1:length(frags); 
        [theta, s_score] = getTheta(frags{ifrag}, edge_occ_id, method); 
        if strcmp(method, 'bin'); 
            s_score = edge_occ_val(frags{ifrag}); 
        end
        sim_score(frags{ifrag}) = s_score; 
        new_occ(frags{ifrag}) = theta; 
        
        if vis
            temp = zeros(size(new_edge)); 
            temp(frags{ifrag})= 1; 
            temp_occ = edge_occ.*imdilate(temp, strel('disk', 5)); 
            
            subplot_tight(2,3,1); imshow(temp, []) ; 
            subplot_tight(2,3,2); imagesc(temp_occ );  axis('image'); 
            subplot_tight(2,3,3); imagesc(new_occ);  axis('image'); 
            subplot_tight(2,3,4); imshow(edge_pred, []) ; 
            subplot_tight(2,3,5); imshow(edge_occ, []) ; 
            %pause; 
        end
    end
    if nargout > 2
        varargout{1} = thin_edge; 
        varargout{2} = sim_score; % whether the edge prediction and orientation prediction is similar
    end
end
