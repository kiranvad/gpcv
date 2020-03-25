% A helper function to set up the data for active learning with knn model 
function [problem, labels, weights, alpha, nearest_neighbors, similarities] = ...
  setup_cvdata(data_design_space, data_cvinput, data_cvouputs)
    problem.points = data_design_space;
    problem.num_points = size(problem.points,1);
    problem.num_classes = 2;
    problem.catdata.inputx = data_cvinput;
    problem.catdata.inputy = data_cvouputs;
    % prior probabilities of the two classes
    alpha               = [0.1 0.9];
    
    nn_file  = 'cvs_nearest_neighbors.mat';
    data_dir = [pwd '/gpcv/data'];
    filename = fullfile(data_dir, nn_file);
    max_k = 100;
    [nearest_neighbors, distances] = ...
        knnsearch(problem.points, problem.points, ...
        'k', max_k + 1);
    save(filename, 'nearest_neighbors', 'distances');

    k = 50;
    nearest_neighbors = nearest_neighbors(:, 2:(k + 1))';
    distances = distances(:, 2:(k + 1))';
    similarities = 1./distances; %exp(-distances.^2/2);
    
    % precompute sparse weight matrix
    num_points = problem.num_points;
    row_index = kron((1:num_points)', ones(k, 1));
    weights = sparse(row_index, nearest_neighbors(:), similarities(:), ...
      num_points, num_points);
    labels =[];
    problem.max_num_influence = max(sum(weights > 0, 1));  % used for pruning

