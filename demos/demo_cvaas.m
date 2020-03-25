%% Set up CV data for Area search
clearvars
load('gpcv/data/traindata_kzd.mat')
load('gpcv/data/gridkzd.mat')
load('gpcv/data/cv_logposts_eckzd.mat')
x_gnd = plot_kzd;
% Set up a GP model
gp_model = struct('inf',@infExact, 'mean', @meanZero, 'cov', @covSEiso, 'lik', @likGauss);
gp_para = struct('mean', [], 'cov', [log(.3);log(0.2)], 'lik', log(.1));
level = 1;

%% Perform Active Area Search 
methods = {'aas','lse','unc','ei','rnd'};
num_experiments = 20;
% Use a random perumation of inputs so that we change intital state of the
% experiment everytime
save_direc = [pwd '/gpcv/plots/AreaSearch'];
if ~exist(save_direc,'dir')
    mkdir(save_direc);
end
recall = {};
for meth = 1:length(methods)
    meth_recall = [];
    for i=1:num_experiments
        problem.points = x_gnd;
        problem.oracle = dummy_ygnd;
        problem.trainind = randperm(size(x_gnd,1),1);
        [temp_recall,tempH]=active_area_search(problem,...
            methods{meth},gp_model,gp_para,level);
        meth_recall = [meth_recall;temp_recall];
        saveas(tempH{2},[save_direc sprintf('/%s_Expt_%d',methods{meth},i) '.png'])
        fprintf('Performed Method: %s \t Experiment: %d \n ',methods{meth},i);
        keybaord;
        close all;
    end
    recall{meth}= meth_recall;
end
save([pwd '/gpcv/data/' 'AAS_Recall.mat'],'recall');

%% Plot Recalls for all the method 
% We avergae over 20 experiments
colors = hsv(length(recall));
for i=1:length(recall)
    plot(mean(recall{1,i}),'LineWidth',2.0,'Color',colors(i,:));
    hold on;
end
hold off;
ylim([0 1]);
fig_labels(2,'xlabel','Iterations','ylabel','Average Recall');
legend(methods,'location','bestoutside','interpreter','latex')




