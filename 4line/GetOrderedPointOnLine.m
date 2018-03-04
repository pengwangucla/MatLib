function Orderedindset = GetOrderedPointOnLine(MyContour, points_num,max_range)
% max_range = 8; 
[frags, new_edge] = GetOrderFrags(MyContour);
ind = cat(1, frags{:}); 
points_idx = zeros(length(ind), 2); 
[points_idx(:,1), points_idx(:,2)] = ind2sub(size(MyContour), ind); 
dist = floor(length(ind)/ points_num); 
idx = 1:dist:length(ind); 
Orderedindset = points_idx(idx, :); 

return 

label = MyContour;
imsize = size(label);
[y, x] = ind2sub(imsize, find(label(:) > 0)); 
points = [y, x]; 

% label = paddingImg(label, max_range); 


Orderedindset = zeros(3,2);
startpt = points(1,:);
Orderedindset(1,:) = startpt;
curdist = 0;
dist = round(size(points,1)/points_num);
curpt = startpt;

i = 1;
shift = cell(1,max_range);
for idis = 1:max_range
    [x,y] = meshgrid(-idis:idis,-idis:idis);
    shift{idis} = [y(:),x(:)];
end
endflag = 0;
reset = 0;
while i <= points_num-1;
    while curdist < dist 
        % update curdist & curpt
        label(curpt(1),curpt(2)) = 0;
        if sum(label(:)) == 0
            endflag = 1;
            break;
        end
        idis = 1;
        s_row = max(curpt(1)-idis, 1); 
        e_row = min(curpt(1)+idis, imsize(1)); 
        s_col = max(curpt(2)-idis, 1); 
        e_col = min(curpt(2)+idis, imsize(2)); 
        next = find(label(s_row:e_row,s_col:e_col));
        
        % go further for get the complexity
        while isempty(next)
            idis = idis + 1;
            if idis > max_range-1 && sum(label(:)) ~= 0 
                reset = 1;
                break;
            end
            s_row = max(curpt(1)-idis, 1);
            e_row = min(curpt(1)+idis, imsize(1));
            s_col = max(curpt(2)-idis, 1);
            e_col = min(curpt(2)+idis, imsize(2));
            next = find(label(s_row:e_row,s_col:e_col));
        end
        if endflag
            break;
        end
        
        %         if idis > max_range
        %             [x,y] = meshgrid(-idis:idis,-idis:idis);
        %             shift{idis} = [y(:),x(:)];
        %             max_range = idis;
        %         elseif isempty(shift{idis})
        %             [x,y] = meshgrid(-idis:idis,-idis:idis);
        %             shift{idis} = [y(:),x(:)];
        %         end
        if reset == 0
            [~,maxind] = max(sum(abs(shift{idis}(next,:))));
            
            % avoid jumping back
            tmppt = repmat(curpt,[size(shift{idis},1),1])+shift{idis};
            tmppt(:,1) = max(min(tmppt(:,1), imsize(1)),1);
            tmppt(:,2) = max(min(tmppt(:,2), imsize(2)), 1);

            ind = sub2ind(size(label),tmppt(:,1),tmppt(:,2));

            label(ind) = 0; %label(curpt(1),curpt(2)) = 1;
            % move to next points
            curpt = curpt+shift{idis}(next(maxind),:);
            curdist = curdist+idis;
            
        elseif reset == 1
            ind = find(label(:)) ;
            [y, x] = ind2sub(imsize, ind);
            id = randperm(length(ind), 1);
            curpt = [y(id), x(id)];
            curdist = 0; 
            reset = 0; 
        end
    end
    
    %     %plot sampled points
%     imshow(MyContour); hold on;
%     plot(Orderedindset(:,2),Orderedindset(:,1),'bo');
%     pause;
    
    if endflag
        break;
    end
    
    Orderedindset(i+1,:) = curpt;
    curdist = 0;
    i = i + 1;
end
