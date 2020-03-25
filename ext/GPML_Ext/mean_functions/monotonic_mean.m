% Computes mean of the type \mu = a*x+b which can be used as a drop in
% replacement for the following type of mean functions given in GPML
% Pacakage : {@meanSum,{@meanLinear,@meanConst}};
% Written by Kiran Vaddi (kiranvad@buffalo.edu)
function [result] = monotonic_mean(theta,x,i,~)
  % report number of hyperparameters
  if (nargin <= 1)
    result = '2*D';
    return;
  end
  
  num_points = size(x, 1);
  
    % evaluate prior mean
  if (nargin == 2)
    result = x * theta(1,:)+ones(num_points,1)*theta(2,:);

  % evaluate derivative with respect to hyperparameter
  elseif (nargin == 3)
      if i==1
          result = x(:, i);
      else
          result = ones(num_points,1);
      end
  % evaluate second derivative with respect to hyperparameter
  else
    result = zeros(num_points, 1);
  end
