
% read a proto txt 
output_sem_height = 20;
output_sem_width = 26; 
semLabel = 6; 
semdim = output_sem_width*output_sem_height; 

% fid = fopen('depth_train_val_joint_softmax_test.prototxt', 'a'); 
fid = fopen('depth_train_val_joint_softmax_test.prototxt', 'a'); 
% line = fgets(fid); 
% while ischar(line)
%     line = fgets(fid); 
% end

for idim = 1:semdim-1
    % generate a output layer 
    if idim < semdim-1
    fprintf(fid, 'layers {\n');
    fprintf(fid, 'name: "split_sem_rest_%d"\n', idim-1);
    fprintf(fid, 'type: SLICE\n');
    fprintf(fid, 'bottom: "split_sem_rest_%d"\n', idim-1);
    fprintf(fid, 'top: "fc7_sem_%d"\n', idim);
    fprintf(fid, 'top: "split_sem_rest_%d"\n', idim);
    fprintf(fid, ' slice_param {\n');
    fprintf(fid, ' slice_dim: 1\n');
    fprintf(fid, [' slice_point: ', num2str(semLabel) ,'\n']);
    fprintf(fid, ' }\n');
    fprintf(fid, '}\n');
    
    % generate a output layer
    fprintf(fid, 'layers {\n');
    fprintf(fid, 'name: "split_semlabel_rest_%d"\n', idim-1);
    fprintf(fid, 'type: SLICE\n');
    fprintf(fid, 'bottom: "split_semlabel_rest_%d"\n', idim-1);
    fprintf(fid, 'top: "sem_label_%d"\n', idim);
    fprintf(fid, 'top: "split_semlabel_rest_%d"\n', idim);
    fprintf(fid, ' slice_param {\n');
    fprintf(fid, ' slice_dim: 1\n');
    fprintf(fid, ' slice_point: 1\n');
    fprintf(fid, ' }\n');
    fprintf(fid, '}\n');
    
    % generate a loss layer 
    fprintf(fid, 'layers {\n');
    fprintf(fid, 'name: "loss_sem_%d"\n',idim);
    fprintf(fid, 'type: SOFTMAX_LOSS\n');
    fprintf(fid, 'bottom: "fc7_sem_%d"\n', idim);
    fprintf(fid, 'bottom: "sem_label_%d"\n',idim);
    fprintf(fid, 'loss_weight: 0.1\n');
    fprintf(fid, '}\n');
    
    elseif idim == semdim-1
        fprintf(fid, 'layers {\n');
        fprintf(fid, 'name: "split_sem_rest_%d"\n', idim-1);
        fprintf(fid, 'type: SLICE\n');
        fprintf(fid, 'bottom: "split_sem_rest_%d"\n', idim-1);
        fprintf(fid, 'top: "fc7_sem_%d"\n', idim);
        fprintf(fid, 'top: "fc7_sem_%d"\n', idim+1);
        fprintf(fid, ' slice_param {\n');
        fprintf(fid, ' slice_dim: 1\n');
        fprintf(fid, [' slice_point: ', num2str(semLabel) ,'\n']);
        fprintf(fid, ' }\n');
        fprintf(fid, '}\n');
        
        % generate a output layer
        fprintf(fid, 'layers {\n');
        fprintf(fid, 'name: "split_semlabel_rest_%d"\n', idim-1);
        fprintf(fid, 'type: SLICE\n');
        fprintf(fid, 'bottom: "split_semlabel_rest_%d"\n', idim-1);
        fprintf(fid, 'top: "sem_label_%d"\n', idim);
        fprintf(fid, 'top: "sem_label_%d"\n', idim+1);
        fprintf(fid, ' slice_param {\n');
        fprintf(fid, ' slice_dim: 1\n');
        fprintf(fid, ' slice_point: 1\n');
        fprintf(fid, ' }\n');
        fprintf(fid, '}\n');
        
        fprintf(fid, 'layers {\n');
        fprintf(fid, 'name: "loss_sem_%d"\n',idim);
        fprintf(fid, 'type: SOFTMAX_LOSS\n');
        fprintf(fid, 'bottom: "fc7_sem_%d"\n', idim);
        fprintf(fid, 'bottom: "sem_label_%d"\n',idim);
        fprintf(fid, 'loss_weight: 0.1\n');
        fprintf(fid, '}\n');
        
        fprintf(fid, 'layers {\n');
        fprintf(fid, 'name: "loss_sem_%d"\n',idim+1);
        fprintf(fid, 'type: SOFTMAX_LOSS\n');
        fprintf(fid, 'bottom: "fc7_sem_%d"\n', idim+1);
        fprintf(fid, 'bottom: "sem_label_%d"\n',idim+1);
        fprintf(fid, 'loss_weight: 0.1\n');    
        fprintf(fid, '}\n');
    end
end 

fclose(fid);