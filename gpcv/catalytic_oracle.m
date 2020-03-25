% A label oracle built using the BMS method to efficiently label a given
% high dimensional response to be either S-shape or not.
% The API is very similar to the label_oracles in the
% active_learning-master folder with following additions
% problem.catdata needs to be added with following fields
% problem.catdata.inputx : Input (t,v) data as a Dx2 matrix where d is
%                          number of time points queried during CV experiments
%                .inputy : Output current value I(t,v) Dxn where n is total
%                          number of points same as problem.points
%   or           .inputx.timemat : nxD time series matrix
%                .inputx.voltmat : nxD voltage matrix
% 
% See also LABEL_ORACLES
%
%(c) Copyright Kiran Vaddi 06-2019
function label = catalytic_oracle(problem, ~, ~, query_ind, ~)
label = [];
for i=1:length(query_ind)
    y = problem.catdata.inputy(:,query_ind(i));
    if isa(problem.catdata.inputx,'struct')
        x = [myNormalizeData(problem.catdata.inputx.timemat(:,query_ind(i))) ...
            problem.catdata.inputx.voltmat(:,query_ind(i))];
    else
        x = problem.catdata.inputx;
    end
    templabel=oracle_cvcatalytic(x,y);
    if templabel==-1
        templabel=2;
    end
    label= [label;templabel];
end
end