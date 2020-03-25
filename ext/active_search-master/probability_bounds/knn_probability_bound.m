% KNN_PROBABILITY_BOUND probability bound for a k-NN classifier.
%
% This function provides a bound for
%
%   \max_i p(y_i = 1 | x_i, D)
%
% after adding additional points to the current training set for a
% k-NN classifier (as implemented in knn_model.m). This bound is
% intended to be used with expected_seach_utility_bound.
%
% Usage:
%
%   bound = knn_probability_bound(responses, train_ind, test_ind, ...
%           weights, max_weights, pseudocount, num_positives)
%
% Inputs:
%
%           problem: a struct describing the problem, containing the
%                    fields:
%
%                  points: an (n x d) data matrix for the avilable points
%             num_classes: the number of classes
%
%         train_ind: a list of indices into problem.points indicating
%                    the thus-far observed points
%   observed_labels: a list of labels corresponding to the
%                    observations in train_ind
%          test_ind: a list of indices into problem.points indicating
%                    the test points
%           weights: an (n x n) matrix of weights
%       max_weights: precomputed max(weights)
%             alpha: the hyperparameter vector \alpha
%                    (1 x problem.num_classes)
%
% Output:
%
%   bound: an upper bound for the maximum posterior probability after
%          adding num_positives positive observations for the points
%          in test_ind.
%
% See also KNN_MODEL, EXPECTED_SEARCH_UTILITY_BOUND, ACTIVE_SEARCH_BOUND_SELECTOR.

% Copyright (c) 2011--2014 Roman Garnett.

function bound = knn_probability_bound(~, train_ind, observed_labels, ...
          test_ind, num_positives, weights, max_weights, alpha)

  % transform observed_labels to handle multi-class
  positive_ind = (observed_labels == 1);

  max_weight = max(max_weights(test_ind));

  successes = sum(weights(test_ind, train_ind( positive_ind)), 2);
  failures  = sum(weights(test_ind, train_ind(~positive_ind)), 2);

  max_alpha = (    alpha(1)      + successes + num_positives * max_weight);
  min_beta  = (sum(alpha(2:end)) + failures);

  bound = max(max_alpha ./ (max_alpha + min_beta));

end