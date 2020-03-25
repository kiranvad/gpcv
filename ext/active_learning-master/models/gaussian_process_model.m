% GAUSSIAN_PROCESS_MODEL a binary Gaussian process classifier.
%
% This is an implementation of a Gaussian process (binary)
% classifier. Requires the GPML toolkit available here:
%
%    <a>http://www.gaussianprocess.org/gpml/code/matlab/doc</a>
%
% Usage:
%
%   probabilities = gaussian_process_model(problem, train_ind, ...
%           observed_labels, test_ind, hyperparameters, inference_method, ...
%           mean_function, covariance_function, likelihood)
%
% Inputs:
%
%               problem: a struct describing the problem, which must
%                        at least contain the field:
%
%                  points: an (n x d) data matrix for the avilable
%                          points
%
%             train_ind: a list of indices into problem.points
%                        indicating the thus-far observed points
%       observed_labels: a list of labels corresponding to the
%                        observations in train_ind
%              test_ind: a list of indices into problem.points indicating
%                        the test points
%       hyperparameters: a GPML hyperparameter structure
%      inference_method: a GPML inference method
%         mean_function: a GPML mean function
%   covariance_function: a GPML covariance function
%            likelihood: a GPML likelihood
%
% Output:
%
%   probabilities: a matrix of posterior probabilities. The first
%                  column gives p(y = 1 | x, D) for each of the
%                  indicated test points; the second column gives
%                  p(y \neq 1 | x, D).
%
% See also MODELS, GP.
% This functiion is slightly modified to fit needs of CV experimental
% active learning by Kiran Vaddi

% Copyright (c) 2011--2016 Roman Garnett.

function varargout = gaussian_process_model(problem, train_ind, ...
          observed_labels, test_ind, hyperparameters, inference_method, ...
          mean_function, covariance_function, likelihood)

  % transform labels to match what GPML expects
  observed_labels(observed_labels ~= 1) = -1;

  num_test = numel(test_ind);
  
  % Find a MLE estimate of hyper paramters
  theta_cap = minimize(hyperparameters,'gp', -100, inference_method, mean_function, covariance_function,...
      likelihood, problem.points(train_ind, :), observed_labels);

  % Fit a GP model and return probabilities
  [ymu, ys2, fmu, fs2, log_probabilities] = gp(theta_cap, inference_method, ...
          mean_function, covariance_function, likelihood, ...
          problem.points(train_ind, :), observed_labels, ...
          problem.points(test_ind, :), ones(num_test, 1));
  % Compute probabilities 
  probabilities = exp(log_probabilities);

  % return probabilities for "class 1" and "not class 1"
  probabilities = [probabilities, (1 - probabilities)];
  
  if nargout==1
      varargout{1} = probabilities;
  elseif nargout==3
      varargout{1} = probabilities;
      varargout{2} = fmu;
      varargout{3} = fs2;
  elseif nargout==5
      varargout{1} = probabilities;
      varargout{2} = fmu;
      varargout{3} = fs2;
      varargout{4} = ymu;
      varargout{5} = ys2;
  end
end
