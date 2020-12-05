%%
load([pwd '\gpcv\data\gridkzd.mat'])
load([pwd '\gpcv\data\traindata_kzd.mat'])
ref_sshape = input_x(:,121);
i = 121;
obj = CatalyticLabelOracle(input_x(:,i),xtr_kzd(:,2),xtr_kzd(:,1),ref_sshape);
[~,fowa_score] = obj.FOWAFit();
[~, ss_score]= obj.SimilaritySearch();
[~, bms_score]= obj.BayesianModelSelection();
fprintf('FOWA : %.2f\nSimilarity Score : %.2f\nBMS Score : %.2f\n', fowa_score, ss_score, bms_score)
   
%% reproduce score plots
manual_selected_cvids = [13588,14558,120,3958,8528,2344,10899,1595,12761,16750];

for i = 1:length(manual_selected_cvids)
    I = cleaned_currmat(:,manual_selected_cvids(i));
    V = cleaned_voltmat(:,manual_selected_cvids(i));
    T = cleaned_timemat(:,manual_selected_cvids(i));
    obj = CatalyticLabelOracle(I,V,T,ref_sshape);
    [~,fowa_score(i)] = obj.FOWAFit();
    [~,sim_score(i)] = obj.SimilaritySearch('euclidean');
    [~,bms_score(i)] = obj.BayesianModelSelection();
    fprintf('FOWA : %.2f\nSimilarity Score : %.2f\nBMS Score : %.2f\n', fowa_score, sim_score, bms_score)
end