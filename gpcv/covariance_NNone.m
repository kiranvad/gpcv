% Neural Network Covariance with Hessian computation for GPML extensions
%
% Copyright (c) by Kiran Vaddi 05-01-2019.

function [K]=covariance_NNone(theta, x, z, i,j)
if nargin==4
    K = covNNone(theta, x, z, i);
elseif nargin==3
    K = covNNone(theta, x, z);
elseif nargin==2
    K = covNNone(theta, x);
elseif nargin<2
    K = covNNone;
else % Build hessians
    ell2 = exp(2*theta(1));
    sf2 = exp(2*theta(2));
    ell = sqrt(ell2);
    nx = size(x,1);
    if isempty(z)
        z = x;
    end
    nz = size(z,1);
    if i==j
        if i==1
            S = 1 + x*z';
            sx = ell2+1 + sum(x.*x,2);
            sz = ell2+1 + sum(z.*z,2);
            a = S./(sqrt(sx).*sqrt(sz)');
            Y = repmat((1./sx),1,nx) + repmat((1./sz)',nz,1);
            X = a./sqrt(1-a.*a);
            dY_dl = -2*ell2*( repmat((1./(sx.*sx)),1,nx) + repmat((1./(sz.*sz))',nz,1) );
            da_dl = -ell.*a.*Y;
            dX_dl = ( (1-a.*a).^(1/2) ).*(1- (a./(1-a.*a))).*da_dl;
            K = -ell*sf2*(2*ell*(X.*Y) + ell2*(Y.*dX_dl) + ell2*(X.*dY_dl) );
        elseif i==2
            K = 4*covNNone(theta, x, z);
        end
    else
        K = 2*covNNone(theta, x, z, 1);
    end
end
