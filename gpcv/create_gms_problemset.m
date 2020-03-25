% Copyright (c) by Kiran Vaddi 05-01-2019.
function [problem]=create_gms_problemset(xtr,ytr)
n = size(xtr,1)/50;
problem.x = [xtr(1:n:end,:);xtr(end,:)];
problem.y = [ytr(1:n:end,:);ytr(end,:)];

test_ind = setdiff(1:size(xtr,1),[1:n:size(xtr,1) size(xtr,1)]);
problem.x_test= xtr(test_ind,:);

if size(xtr,2)==1
    if length(problem.x_test)<=100
        problem.x_test = linspace(min(xtr),max(xtr),1e3)';
    end
end