% Copyright (c) by Kiran Vaddi 05-01-2019.

function [tempY]=myNormalizeData(X,varargin)
tempY = [];
for i=1:size(X,2)
    tempX = (X(:,i)-min(X(:,i))*(ones(size(X(:,i)))))./range(X(:,i));
    tempY = [tempY tempX];
end
