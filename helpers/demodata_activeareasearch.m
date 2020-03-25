function [y]=demodata_activeareasearch(n)
xmin = -0.2;
xmax = 0.8;
x = unifrnd(xmin, xmax, n, 2);
y = fun_cosines(x(:, 1), x(:, 2));