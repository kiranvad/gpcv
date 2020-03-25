% A helper function to run Active Area Search
% active_area_search(problem,method,gp_model,gp_para,level)
% Inputs : 
% ===========
% problem   :   Following fiels are required
%                 'points'      --  Search space points as nxd
%                 'oracle'      --  Oracle to compute values at a given location.
%                                   Can be a function handle (requires oracleX and oracleY to evaluate relavnt Y value)
%                                   or a relavant matrix of nx1
%                 'trainind'    --  Training indices for the search space
% method    :   Following area search methods available:
%                 'lse' -- Level Set Estimation
%                 'aas' -- Active Area Search
%                 'unc' -- Uncertainity Sampling
%                 'ei'  -- Expected Improvement
%                 'rnd' -- Random sampling
% gp_model    :   Gaussian Process model as a strcture: 
%                 Example: gp_model = struct('inf',@infExact, 'mean', @meanZero, 'cov', @covSEiso, 'lik', @likGauss);
% gp_para     :   Gaussian Parameters 
%                 Example: gp_para = struct('mean', [], 'cov', [log(.3);log(2)], 'lik', log(.1));
% level       :   Leveset of function f to be estimated
% 
% Following optiional inputs avaialble:
% 'plot'          :   To visualize (1)-Actual contour (2)Active search trace (3)Utility function trace
%                     Works for 2D plots only
% 'num_regions'   :   Number of regions in the grid approximation of the region (default, 10)
% 'queryLen'      :   Number of queries to be made (default, 50)
% 'highprob'      :   \theta value to be considered for the probability from Ma et.al 2014 (default, 0.5)
% 'side'          :   Kind of an unknown parameter set it to 1
% 'xshape'        :   Shape Grid of original space (default, [] which just 
%                     interplotates the function value to an approxiamte grid)
% Outputs:
% =========
% recall  :   Recall value over itereations

% This helperfunction requires the following packages:
% Active Area Searhch : https://github.com/yifeim/active-area-search

% Copyright (c) by Kiran Vaddi 07-01-2019.

function [varargout]=active_area_search(problem,method,gp_model,gp_para,level,varargin)
%% Parse optional inputs
pars.plot = 1;
pars.num_regions = 10;
pars.queryLen = 30;
pars.highprob = 0.5;
pars.side = 1;
pars.xshape = [];
pars.plotshow = 'off';

pars = extractpars(varargin,pars);
%% Parse problem type input to x and y 
x_gnd = problem.points;
if isa(problem.oracle,'function_handle')
    y_gnd = problem.oracle(problem.oracleX,problem.oracleY);
else
    y_gnd  = problem.oracle;
end
if ~isempty(problem.trainind)
    flag_train = 1;
    trainind = problem.trainind;
end
%% Set up regions for area search
xmin = min(x_gnd(:,1));ymin = min(x_gnd(:,2));
xmax = max(x_gnd(:,1));ymax = max(x_gnd(:,2));

xshift  = linspace(xmin,xmax,pars.num_regions);
xshift = xshift(end)-xshift(end-1);

yshift  = linspace(ymin,ymax,pars.num_regions);
yshift = yshift(end)-yshift(end-1);

[region_X1, region_X2] = meshgrid(linspace(xmin,xmax-xshift,pars.num_regions-1),...
    linspace(ymin,ymax-yshift,pars.num_regions-1));
regions  = [region_X1(:), region_X1(:)+xshift, region_X2(:), region_X2(:)+yshift];

%% Select Plot modes
if size(x_gnd,1)==size(y_gnd,1)
    flag_gnd = 1;
else
    flag_gnd = 0;
end
if isempty(pars.xshape) || (pars.xshape(1)~=pars.xshape(2))
    plotflag = 2;
else 
    plotflag = 1;
end
%% Set up ground truth and related plots
if flag_gnd
    gnd =   ActiveAreaSearch(gp_model, gp_para, x_gnd, regions,level, pars.side, pars.highprob);
    region_outcome_gnd =   gnd.update(x_gnd, y_gnd);
    
    if pars.plot
        h1=figure(1);set_figures(h1);clf
        
        switch plotflag
            case 1
                [~, ~, f, fs2] = gnd.predict_points(x_gnd);
                plot_demo(pars.xshape, x_gnd, f, fs2, [], regions, level, gnd.alpha, gnd.beta2,...
                    region_outcome_gnd, 'plotTailGaussian', false);
            case 2
                uneven_contour(h1,x_gnd,y_gnd,[],level, regions, gnd.alpha, gnd.beta2,...
                    region_outcome_gnd);
                hold on;
                plot_patches(regions, 'rule');
        end
        title('Actual contour');
    end
end
%% Select an Area Search Method
switch method
    case 'aas'
        asm = ActiveAreaSearch(gp_model, gp_para,x_gnd, regions, level, pars.side, pars.highprob);
    case 'lse'
        asm = ActiveLevelSetEstimation(gp_model, gp_para, x_gnd, level, 9, 0.1);
    case 'unc'
        asm = UncertaintySampling(gp_model, gp_para, x_gnd);
    case 'ei'
        asm = ExpectedImprovement(gp_model, gp_para, x_gnd);
    case 'rnd'
        asm = RandomSampling(gp_model, gp_para, x_gnd);
    otherwise
        error('No such method exists.Stop kidding youself :) \n');
end

%% Perfom active area search
region_measure_method   =   ActiveAreaSearch(gp_model, gp_para, x_gnd, regions,level, pars.side, pars.highprob);
recall = [];
if flag_train
    asm.update(x_gnd(trainind, :), y_gnd(trainind, :));
end
for query_count = 0:pars.queryLen-1
    
    u = asm.utility();
    [~, ind] = max_tiebreak(u);
    
    asm.update(x_gnd(ind, :), y_gnd(ind, :));
    found = region_measure_method.update(x_gnd(ind, :), y_gnd(ind, :));
    
    if pars.plot
        if query_count<9
            h2=figure(2);set_figures(h2);clf
            set(h2, 'NumberTitle', 'off', ...
                'Name', sprintf('Query: %d', query_count+1));
            [~, ~, f, fs2] = asm.predict_points(x_gnd);
            switch plotflag
                case 1
                    plot_demo(pars.xshape, x_gnd, f, fs2, asm.collected_locs, regions, level,...
                        region_measure_method.alpha, region_measure_method.beta2, found,...
                        'plotTailGaussian', false);
                case 2
                    uneven_contour(h2,x_gnd,f,fs2,level, regions,...
                        region_measure_method.alpha, region_measure_method.beta2, found);
                    hold on;
                    plot_patches(regions, 'rule');
                    scatter(asm.collected_locs(:,1), asm.collected_locs(:,2), 50, 'k','s','filled');
                    text_cell = cellstr(num2str([0:query_count+length(problem.trainind)]'));
                    text(asm.collected_locs(:,1)+0.1, asm.collected_locs(:,2)+0.1,...
                        text_cell, 'Fontsize', 10);
                    hold off;
            end
        end
        h3=figure(3);set_figures(h3);clf
        titleString = sprintf('%s Query: %d',method,query_count+1);
        set(h3, 'NumberTitle', 'off', ...
            'Name', titleString);
        switch plotflag
            case 2
            uneven_contour(h3,x_gnd,u);
            case 1
            imagesc(reshape(u, pars.xshape));
        end
        pause(0.2);
    end
    % Compute recall
    if flag_gnd
        recall(query_count+1) = (0+region_measure_method.cumfound>0)'*region_outcome_gnd ...
            / sum(region_outcome_gnd);
        if query_count == pars.queryLen-1
            fprintf('Final recall: %0.2f\n',recall(end));
        end
    end
end

%% Parse output mode
if nargout <1
    fprintf('Learning terminated!\n')
elseif (nargout==1)&&(flag_gnd)
    varargout{1} = recall;
elseif nargout==2
    H{1}=h1;H{2}=h2;H{3}=h3;
    varargout{1} = recall;
    varargout{2} = H;
end

function []=set_figures(handle)
pos = [0,0.35,0.65];
handle.Units = 'normalized';
handle.Position = [pos(handle.Number) 0.4 0.3 0.3];

function []=uneven_contour(h,x_view,f_view,fs2_view,level, regions,...
                    alpha, beta2, found)
[t1new,t2new]=meshgrid(x_view(:,1),x_view(:,2));
probmat =griddata(x_view(:,1),x_view(:,2),f_view,t1new,t2new);
 
switch h.Number
    case 1
        patchplot = 1;
        granularity = regions(1,2) - regions(1,1);
        [~,h] = contourf(t1new, t2new, probmat);
        set(h, 'LineColor','none');
        colormap(brighten(jet, .7));
        colorbar;
    case 2
        patchplot = 1;
        granularity = regions(1,2) - regions(1,1);
        colormat = griddata(x_view(:,1),x_view(:,2),fs2_view,t1new,t2new);        
        siz         = [min(regions(:,1)), max(regions(:,2)), min(regions(:,3)), max(regions(:,4))];
        color_shaped = colorlookup(sqrt(max(colormat(:),0)),[0, 3], 1-gray);
        image([siz(1), siz(2)], [siz(3),siz(4)],reshape(color_shaped,[size(t1new),3]));
        set(gca,'yDir','normal');
    case 3
        patchplot = 0;
        imagesc([min(x_view(:,1)) max(x_view(:,1))], [min(x_view(:,2)) max(x_view(:,2))], probmat);
        set(gca,'yDir','normal');
        colormap(brighten(jet, .7));
        colorbar;
end


if patchplot
    hold on;
    for i=1:length(regions)
        plot_tick_cross([
            .5*regions(i,1)+.5*regions(i,2)
            .5*regions(i,3)+.5*regions(i,4)
            ], .2*granularity, level, alpha(i), sqrt(beta2(i)), found(i), 1);
    end
    hold off;
end

