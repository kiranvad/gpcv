% SEARCH_UTILITY simple "Battleship" utility for active search.
%
% This file provides an implementation of the active search utility
% function for use in the MATLAB active learning toolbox. Here the
% utility is defined to be the number of "interesting" points found,
% where interesting is defined by membership to class 1:
%
%   u(D) = \sum_i \chi(y_i = 1)
%
% Note that this utility should typically not be used directly in,
% e.g., expected_loss_naive. For this utility, the expected utility
% can be calculated in closed form; see search_expected_utility.m.
%
% Usage:
%
%   utility = search_utility(problem, train_ind, observed_labels)
%
% Inputs:
%
%           problem: a struct describing the problem, containing
%                    the field:
%
%              points: an (n x d) data matrix for the available points
%
%                    Note: this input is ignored by search_utility.
%                    If desired, it can be replaced by an empty matrix.
%
%         train_ind: a list of indices into problem.points indicating
%                    the thus-far observed points
%
%                    Note: this input is ignored by search_utility.
%                    If desired, it can be replaced by an empty matrix.
%
%   observed_labels: a list of labels corresponding to the
%                    observations in train_ind
%
% Output:
%
%   utility: the utility of the selected points
%
% See also SEARCH_EXPECTED_UTILITY, LOSS_FUNCTIONS.

% Copyright (c) Roman Garnett, 2011--2014

function utility = search_utility(~, ~, observed_labels)

  utility = nnz(observed_labels == 1);

end
