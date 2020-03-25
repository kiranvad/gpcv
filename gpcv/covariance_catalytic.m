% Copyright (c) by Kiran Vaddi 05-01-2019.

function [K] = covariance_catalytic(theta, x, z, i,j) 
if nargin<2, K = '3'; return; end                  % report number of parameters
if nargin<3, z = []; end                                   % make sure, z exists
xeqz = isempty(z); dg = strcmp(z,'diag');                       % determine mode

[~,D] = size(x);
if D>1, error('Covariance is defined for 1d data only.'), end
ell = exp(theta(1));
sf2 = exp(2*theta(3));
p = exp(theta(2));

% p   = 0.5*(x(end)-x(1)); % Set the periodicity of catalytic regime to be ramp switch voltage
%p=5;

% precompute distances
if dg                                                               % vector kxx
  Kxxp = zeros(size(x,1),1);
else
  if xeqz                                                 % symmetric matrix Kxx
    Kxxp = sqrt(sq_dist(x'));
  else                                                   % cross covariances Kxz
    Kxxp = sqrt(sq_dist(x',z'));
  end
end

m = pi*Kxxp/p;
R = sin(m).*sin(m); % R = sin^2(pi*(x-x')/p)

if nargin<4
    K = covPeriodic(theta, x, z);
elseif nargin==4
    K = covPeriodic(theta, x, z,i);
elseif nargin==5
    if (i==1)&&(j==1)
        K = (4*sf2*R).*exp(-(2*R/(ell^2))).*((4*R/(ell^4))-(2/(ell^2)));        % 11 entry
    elseif (i==3)&&(j==1)
        K = ((8*R*sf2)/(ell^2)).*exp(-(2*R/(ell^2)));                          % 31 or 13 entry 
    elseif (i==3)&&(j==3)
        K = 4*sf2*exp(-(2*R/(ell^2)));                                      % 33 entry
    elseif (i==2)&&(j==1)
        K = (2*ell*m).*covariance_catalytic(theta, x, z)...                    % 21 or 12 entry
            .*sin(2*m).*((-2/ell^3)+(R*(4/ell^5)));
    elseif (i==3)&&(j==2)
        K = 2*covariance_catalytic(theta, x, z,2);                            % 32 or 23 entry
    elseif (i==2)&&(j==2)
        K = (4/ell^2)*(2*m.*sin(m).*covariance_catalytic(theta, x, z,2)-...
            2*covariance_catalytic(theta, x, z).*m.*sin(m)...
            -2*covariance_catalytic(theta, x, z).*m.*cos(m).*m);         % 22 entry
    elseif i<j
        K = covariance_catalytic(theta, x, z, j,i);                         % using the symmetry
    else
        error('Unknown hyperparameter')
    end
end
    
    