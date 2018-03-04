function [feature, params] = FeatureMapping(ofeat, params)
% learning the feature mapping model 
% ofeat is a nxd matrix 
% feature is a n x d2 matrix
if ~exist('params','var')
    params.codetype = 'pca';
    params.pcatype = 'energy';
    params.verbose = 1;
end
if isfield(params,'type') & ~isfield(params,'codetype');
    params.codetype = params.type;
end

switch params.codetype
    case 'pca'
        disp('        pca');
        if isfield(params,'mapping')
            ofeat = bsxfun(@minus, ofeat, params.meanvalue );
            feature = ofeat*params.mapping;
        else
            params.meanvalue = mean(ofeat);
            ofeat = bsxfun(@minus, ofeat, params.meanvalue );
            if ~isfield(params,'pcatype')
                params.pcatype = 'energy';
            end
            if strcmp(params.pcatype,'energy');
                option.energyrate = 0.9;
                option.energy = 1;
            else
                option.energy = 0;
            end
            
            [feature,params.mapping] = pca_ml(ofeat', params.dim, option);
            
            feature = feature';
        end
    case 'kmeans'
        disp('        kmeans');
        if ~isfield(params,'centernum')
            params.centernum = 1000;
        end
        if ~isfield(params,'kernelparam');
            params.kernelparam = 0.1;
        end
        if isfield(params, 'mapping')
            D =  eval_kernel(ofeat,params.mapping, 'dist2');
        else
            try
                if isfield(params,'maxiter');
                    opts = statset('MaxIter',params.maxiter);
                else
                    opts = statset('MaxIter',100);
                end
                [~,params.mapping,~,D] = kmeans(ofeat,params.centernum, 'Options',opts);
            catch
                params.mapping = kmeans(ofeat',params.centernum);
                params.mapping = params.mapping';
                D = eval_kernel(ofeat,params.mapping, 'dist2');
            end
        end
        %feature = eval_kernel(ofeat,mapping, 'rbf',params.kernelparam);
        feature = exp(-params.kernelparam*D);
        %feature(feature < 0.01) = 0;
    case 'sparseCode'
        
    case 'sparseAotuencoder'
        disp('Start feature coding')
        visibleSize = size(ofeat,2);  % number of input units
        hiddenSize = params.hiddensize;   % number of hidden units
        
        if isfield(params,'mapping')
            feature = feedForwardAutoencoder(params.mapping, hiddenSize, visibleSize, ...
                ofeat');
            feature = feature';
        else
           
%            theta = initializeParameters(hiddenSize, visibleSize);
%             [~, ~] = sparseAutoencoderCost(theta, visibleSize, hiddenSize, lambda, ...
%                 sparsityParam, beta, patches);
%             
            %  Randomly initialize the parameters
            theta = initializeParameters(hiddenSize, visibleSize);
            
            %  Use minFunc to minimize the function
            % addpath minFunc/
            sparsityParam = 0.01;   % desired average activation of the hidden units.
            lambda = 0.0001;     % weight decay parameter
            beta = 3;            % weight of sparsity penalty term
            options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost
            options.maxIter = 400;	  % Maximum number of iterations of L-BFGS to run
            options.display = 'off';
            
            [mapping, cost] = minFunc( @(p) sparseAutoencoderCost(p, ...
                visibleSize, hiddenSize, ...
                lambda, sparsityParam, ...
                beta, ofeat'), ... % ofeat is a n x d feature  require d x n
                theta, options);
            params.mapping = mapping;
            feature = feedForwardAutoencoder(mapping, hiddenSize, visibleSize, ...
                ofeat');
            feature = feature';
        end
        if isfield(params,'verbose') 
            if params.verbose == 1
                %visualize the trained results
                W1 = reshape(params.mapping(1:hiddenSize * visibleSize), hiddenSize, visibleSize);
                display_network(W1');
            end
        end
    case 'none'
        feature = ofeat;
end

end