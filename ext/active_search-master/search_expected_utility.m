% SEARCH_EXPECTED_UTILITY one-step lookahed expected search utility.
%
% This file provides a score function computing the expected one-step
% lookahead search utility for each of a given set of points for use
% in the MATLAB active learning toolbox. Here the search utility is
% defined to be the number of "interesting" points found, where
% interesting is defined by membership to class 1:
%
%   u(D) = \sum_i \chi(y_i = 1)
%
% and the expected utility after adding a point x to D can be
% calculated as:
%
%   E[u(D \cup {(x, y)}) | x, D] = u(D) + p(y = 1 | x, D),
%
% where p(y = 1 | x, D) is given by a probability model. The fact
% that we can compute the expected utility in closed form allows us
% to avoid explicitly sampling over the label y. This function can
% be used directly as a score function or used as an expected
% utility in, e.g., expected_utility_lookahead.
%
% Usage:
%
%   expected_utilities = search_expected_utility(problem, train_ind, ...
%           observed_labels, test_ind, model)
%
% Inputs:
%
%           problem: a struct describing the problem, containing fields:
%
%                  points: an (n x d) data matrix for the available points
%             num_classes: the number of classes
%
%         train_ind: a list of indices into problem.points indicating
%                    the thus-far observed points
%   observed_labels: a list of labels corresponding to the
%                    observations in train_ind
%          test_ind: a list of indices into problem.points indicating
%                    the points eligible for observation
%             model: a handle to the probability model to use
%
% Output:
%
%   expected_utilities: the expected utilities after observing each of
%                       the points in test_ind
%
% See also SEARCH_UTILITY, SCORE_FUNCTIONS, MODELS.

% Copyright (c) Roman Garnett, 2011--2014

function expected_utilities = search_expected_utility(problem, ...
          train_ind, observed_labels, test_ind, model)

  probabilities = model(problem, train_ind, observed_labels, test_ind);

  % expected utility after adding x is simply u(D) + p(y = 1 | x, D)
  expected_utilities = search_utility([], [], observed_labels) + ...
      probabilities(:, 1);

end