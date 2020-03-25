% Computes the Following Given the Model Evidences as a vector
% p(M|D) = p(y|M,D)*p(M)/sum( p(y|M_i,D)*p(M_i))
% By taking logarithm of the above we get the following:
% log(p(M_j|D)) = -log[(1+sum_{i\neqj}(exp(log(p(y|M_i,D)/exp(log(y|M_j,D))))))]

% Copyright (c) by Kiran Vaddi 05-01-2019.

function [model_posterior]=model_posterior(model_evidences)

i = 1:length(model_evidences);
for j=1:length(model_evidences)
    model_posterior(j)=-log(1+sum((exp(model_evidences(i~=j)))/(exp(model_evidences(j)))));
end