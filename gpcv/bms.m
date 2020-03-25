function [results]=bms(models,problem,varargin)
% Performs Bayesian Model Selection for a given set of models and a problem
% which needs to be decribed as follows: 
% Inputs: 
% -------
%         models      : A cell which has structures with the following fields 
%                         inference_method    :   Inference method to be used (exact inference recommened if using MGP)
%                         likelihood          :   Likelihood (if using MGP, set it to [])
%                         mean_function       :   Mean function of the given model
%                         covariance_function :   Covariance function of the given model
%                         
%         problem     :  A struct with the following fields
%                         x       :   Input training data
%                         y       :   Output training data
%                         x_test  :   Input test data
%                         
%         'usemgp'    :   Set it 1 (to use MGP for predictions, restriction on models of MGP apply), 0 (otherwise)
%         'Ncg'       :   Number of conjugate gradient descent steps (GPML toolbox)
% Outputs:
% --------
%         results     : A cell with structs containing the following fields
%                         y_star_mean     :   Test data predicted mean
%                         y_star_mean     :   Test data precited variance
%                         log_evidence    :   Model log evidence
%                         
% See also, theta_posterior_laplace , gp , mgp                        
  
% Copyright (c) by Kiran Vaddi 05-01-2019.

pars.usemgp = 0;
pars.Ncg = 50;
pars.plot = 1;

pars = extractpars(varargin,pars);

for i=1:length(models)
    if pars.usemgp
        gpfunc = str2func('mgp');
    else
        gpfunc = str2func('gp');
    end
    inference_method = @exact_inference;
    likelihood = [];%@gauss_likelihood;
    models{i}.hyp0.lik=0;
    % Compute Hyperparameter \theta^cap
    compute_hypers = minimize(models{i}.hyp0, @gp, pars.Ncg, inference_method, ...
        models{i}.mean_function, models{i}.covariance_function, likelihood, problem.x, problem.y);

    % Compute Preictions using GP
    if isfield(problem,'x_test')
        [mean, variance,~] = gpfunc(compute_hypers, inference_method, models{i}.mean_function, ...
            models{i}.covariance_function, likelihood, problem.x, problem.y, problem.x_test);
        results{i}.y_star_mean = mean;
        results{i}.y_star_var = variance;
    end
    % Compute Log Evidence
    [~, ~, log_evidence] = theta_posterior_laplace(compute_hypers, @exact_inference, ...
        models{i}.mean_function, models{i}.covariance_function, @gauss_likelihood, problem.x, problem.y);    

    results{i}.log_evidence = log_evidence;

end

if (pars.plot)&&(isfield(problem,'x_test'))
    for i=1:length(results)
        model_evidences(i)=real(results{i}.log_evidence);
    end
    model_posteriors = model_posterior(model_evidences);
    for i=1:length(models)
        subplot(length(models),1,i)
        ysd = sqrt(results{i}.y_star_var);
        ymu = results{i}.y_star_mean;
        plot(problem.x,problem.y,'+','Color','k');
        hold on;
        plot(problem.x_test,ymu,'LineWidth',2.0,'Color','red')
        fill([problem.x_test;flipud(problem.x_test)],...
            [ymu+ysd;flipud(ymu-ysd)],...
            'red','EdgeColor','red','FaceAlpha',0.1,'EdgeAlpha',0.3);
        hold off;
        title(sprintf('Model Posterior log(p(M|D)): %0.2f',exp(model_posteriors(i))))
    end
end

