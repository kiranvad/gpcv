function [varargout] = gauss_likelihood(theta, y, mu,~, ~,~, ~)
if nargin<=3
    varargout = {likGauss};    
end

if nargin==5
    sn2 = exp(2*theta);

    ymmu = y-mu;
    lp = -ymmu.^2/(2*sn2) - log(2*pi*sn2)/2;
    dlp = ymmu/sn2;
    d2lp = -ones(size(ymmu))/sn2;
    d3lp = zeros(size(ymmu));
    d4lp = zeros(size(ymmu));
    varargout = {lp,dlp,d2lp,d3lp,d4lp};
    
elseif nargin ==6
    sn2 = exp(2*theta);

    lp_dhyp = (y-mu).^2/sn2 - 1;  % derivative of log likelihood w.r.t. hypers
    dlp_dhyp = 2*(mu-y)/sn2;                               % first derivative wrto \mu,
    d2lp_dhyp = 2*ones(size(mu))/sn2;   % and also of the second mu derivative
    d3lp_dhyp = zeros(size(mu));   % and also of the third mu derivative
    
    varargout = {lp_dhyp,dlp_dhyp,d2lp_dhyp,d3lp_dhyp};
elseif nargin ==7
    sn2 = exp(2*theta);

    lp_dhyp2 = -2*(y-mu).^2/sn2;
    dlp_dhyp2 = 4*(y-mu)/sn2;
    d2lp_dhyp2 = -4*ones(size(mu))/sn2;
    varargout={lp_dhyp2, dlp_dhyp2, d2lp_dhyp2};
end
end