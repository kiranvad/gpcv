function [lME]=model_evidence(X,y,theta_cap,M,SigmaInv)
% Computes the following
% Model Evidence    term1                       term2                       term3               term4                                             
% log p(y | X,M) ~ log p(y | X,theta_cap,M) + log p(theta_cap | M) - 1/2* log det(SigmaInv)+ d/2 log(2*pi)

term1 = gp(theta_cap, M.inf, M.mean, M.cov, M.lik, X, y);

term2 = 0;

term3 = (1/2)* log(det(SigmaInv));

term4 = (numel(theta_cap)/2)*log(2*pi);

lME = term1+term2+term3+term4; % Log Model Evidence log p(y | X,M);