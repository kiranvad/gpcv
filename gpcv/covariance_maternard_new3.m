% Automatic Relavance Determinantion Matern Covariance function with
% Hessian Computations
% Implemented for One dimensional data with degree 3 i.e. f(t) = 1+t
% This is function is compatiable with GPML Extensions
%
% Copyright (c) by Kiran Vaddi 05-01-2019.

function [K]=covariance_maternard_new3(theta,x,z,i,j)
if nargin<1
    K = covMaternard(3);
elseif nargin==2
    K = covMaternard(3,theta,x);
elseif nargin==3
    K = covMaternard(3,theta,x,z);
elseif nargin==4
    K = covMaternard(3,theta,x,z,i);
else  % Hessians computation mode
    [~,D]=size(x);
    ell = exp(theta(1:D));
    d = 3;
    if isempty(z)
        z = x;
    end
    if i==j
        if i<=D
            r = sq_dist(diag(sqrt(d)./ell)*x',diag(sqrt(d)./ell)*z');
            
            ri = sq_dist(diag(sqrt(d)/ell(i))*x',diag(sqrt(d)/ell(i))*z');
            
            factor = ones(size(ri))+ell(i)*(ri+(ri./r));
            K = -factor.*covMaternard(3,theta,x,z,i);
            K(ri<1e-12) = 0;
        elseif i==D+1
            K = 4*covMaternard(3,theta,x,z);
        else
            error('Unknown hyperparameter')
        end
    elseif i~=j
        if max(i,j)<D+1
            sf2 = theta(D+1);
            r = sq_dist(diag(sqrt(d)./ell)*x',diag(sqrt(d)./ell)*z');
            
            ri = sq_dist(diag(sqrt(d)/ell(i))*x',diag(sqrt(d)/ell(i))*z');
            rj = sq_dist(diag(sqrt(d)/ell(j))*x',diag(sqrt(d)/ell(j))*z');
            
            K = sf2*ell(i)*ell(j)*ri.*rj.*(r-ones(size(r))).*exp(-r);
        else
            K = 2*covMaternard(3,theta,x,z,min(i,j));
        end
    elseif (i>D+2) || (j>D+2)
        error('Unknown hyperparameter');
    end
end



