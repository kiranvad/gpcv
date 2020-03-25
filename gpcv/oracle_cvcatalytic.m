% An oracle which turns in a label +1 if the data can be intrepreted to be
% catalytic CV curve -1 if not. This is done using a Bayesian
% Model Selection
% See also, bms

% Copyright (c) by Kiran Vaddi 05-01-2019.

function [label,Details]=oracle_cvcatalytic(x,y)


mean_functions = {'zero_mean','zero_mean'};
cov_functions = {'ard_sqdexp_covariance','covariance_NNone'};
length_scale = 0.1;
noise_scale = 0.25;

hyp1_0.mean = [];
hyp1_0.cov = log([length_scale*ones(size(x,2),1);noise_scale]);
hyp1_0.lik = log(noise_scale);

hyp2_0.mean = [];%[];%mean2(xtr);
hyp2_0.cov = log([length_scale;noise_scale]);
hyp2_0.lik = log(noise_scale);

% Set up Models for BMS

% Model 1
model1.mean_function = mean_functions{1};
model1.covariance_function = cov_functions{1};
model1.hyp0 = hyp1_0;
% Model 2 (catalytic)
model2.mean_function = mean_functions{2};
model2.covariance_function = cov_functions{2};
model2.hyp0 = hyp2_0;

% Setup Models for BAMS
models{1}=model1;
models{2}=model2;

% Set up Problem
[problem]=create_gms_problemset(x,y);


[results]=bms(models,problem,'plot',0,'Ncg',-150,'usemgp',0);

for i=1:length(results)
    model_evidences(i)=results{i}.log_evidence;
end
model_posteriors = model_posterior(model_evidences);

% Attach/Turn in a label
[~,ind]=max(-model_posteriors);
if ind==2
    label=1;
else
    label=-1;
end
Details.model1=results{1};
Details.model2=results{2};
Details.posts = model_posteriors;
Details.modelevidence = model_evidences;


