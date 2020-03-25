% Active learning of Combinatorial Experiments using batch search for
% Cyclic Voltammetry responses
%% Add GPCV package to the path
clearvars
close all
%% Prelimenaries (Independent of Problem at hand)
policy_codes  % defines policies coded by constant numbers
policies            = [GREEDY, SS_TWO_0, BATCH_ENS];

% set this to 1 if you want to plot the selected point (2D problem only)
visualize           = 1;
% set this to 1 if you want to print info for every iteration
verbose             = 0;

% if batch_size = 1, perform fully sequential active search
batch_size          = 5;%[2,3,4,5];  % number of points in each batch query
%num_queries         = 20; % number of batch queries
total_label_queries = 20;

num_initial         = 1;  % number of initial positive training points

num_experiments     = 1;  % number of experiments to repeat
num_policies        = length(policies);

%% Setup your data
% We use a function which sets up the data given design space, experimental responses of CVs
data_type = 'kzd';
switch data_type
    case 'kzd'
        load('gpcv/data/traindata_kzd.mat')
        load('gpcv/data/gridkzd.mat')
        [problem, labels, weights, alpha, nearest_neighbors, similarities] = ...
            setup_cvdata(plot_kzd, xtr_kzd, input_x);
        true_labels = 2*ones(size(idx_manual));
        true_labels(idx_manual==6)=1;
        label_oracle        = get_label_oracle(@catalytic_oracle, labels);

    case 'fullec'
        load('gpcv/data/fullec_active_search_data.mat')
        [problem, labels, weights, alpha, nearest_neighbors, similarities] = ...
            setup_cvdata(cleaned_grid, [], []);
        true_labels = [cleaned_ygnds.label];
        true_labels(true_labels==-1)=2;
        label_oracle        = get_label_oracle(@lookup_oracle, true_labels');
end
%% setup problem
problem.verbose     = verbose;  % set to true for debugging/verbose output
problem.num_initial = num_initial;

%% setup model
model       = get_model(@knn_model, weights, alpha);
model       = get_model(@model_memory_wrapper, model);

%% Run active learning experiments
for batch = 1:length(batch_size)
    problem.batch_size  = batch_size(batch);
    problem.num_queries = total_label_queries/batch_size(batch);  % note this is the number of batch queries

    total_num_queries   = problem.num_queries * problem.batch_size;
    num_targets = nan(total_num_queries, num_experiments, num_policies);

    for pp = 1:length(policies)
        policy = policies(pp);
        
        % set up the function of bounding the probabilities
        if policy == 2 || policy > 30
            tight_level = 4;
            probability_bound = get_probability_bound_improved(...
                @knn_probability_bound_improved, ...
                tight_level, weights, nearest_neighbors', similarities', alpha);
        else
            probability_bound = get_probability_bound(@knn_probability_bound, ...
                weights, full(max(weights)), alpha);
        end
        
        % setup policy
        [query_strategy, selector] = get_policy(policy, problem, model, ...
            weights, probability_bound);
        
        if visualize
            callback = @(problem, train_ind, observed_labels) ...
                activeplot2d(problem, train_ind, observed_labels);
        else
            callback = @(problem, train_ind, observed_labels) [];
        end
        
        pos_ind = find(true_labels == 2); % Start from any Non S-shape CV curve
        
        for experiment = 1:num_experiments
            rng(experiment);
            fprintf('\nRunning policy %d experiment %d...\n', policy, experiment);
            
            % randomly sample num_initial positives as initial training data
            train_ind = randsample(pos_ind, num_initial);
            
            observed_labels = 2*ones(length(train_ind),1);
            
            % run active search cycle for formulated problem
            [chosen_ind, chosen_labels] = active_learning(problem, train_ind, ...
                observed_labels, label_oracle, selector, query_strategy, callback);
            keyboard;
            % collect results
            num_targets(:, experiment, pp) = cumsum(chosen_labels==1);
        end
    end
    num_file_name = [pwd '/num_targets_' num2str(problem.batch_size) '.mat'];
    save(num_file_name,'num_targets');
end
%% Plot number of targets found
figure;
for i=1:size(num_targets,3)
    frac_targets = mean(num_targets(:,:,i),2);
    plot(frac_targets,'LineWidth',2.0); hold on;
end
hold off;
fig_labels(2,'xlabel','Iterations','ylabel','$\#$ of Targets')
xlim([0 size(num_targets,1)]);ylim([0 size(num_targets,1)])
legend({'GREEDY', 'SS-TWO-0', 'BATCH-ENS'},'Location','best','interpreter','latex')