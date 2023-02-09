clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'cue';
TIME_BEFORE = 0;
TIME_AFTER = 800;

req_params = reqParamsEffectSize("both");
req_params.cell_type = {'PC ss','CRB'};
req_params.remove_question_marks = false;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    
    boolFail = [data.trials.fail];
    
    CV2(ii) = getCV2(data,find(~boolFail),EPOCH,TIME_BEFORE,TIME_AFTER);
    FR(ii) = getFR(data,find(~boolFail),EPOCH,TIME_BEFORE,TIME_AFTER);
    CV(ii) = getCV(data,find(~boolFail),EPOCH,TIME_BEFORE,TIME_AFTER);
end

%%
figure
subplot(2,1,1)
gscatter(CV2,FR,cellType')
ylabel('FR'); xlabel('CV2')

subplot(2,1,2)
gscatter(CV,FR,cellType')
ylabel('FR'); xlabel('CV')

%% PCA for CRB

inx = find(strcmp(cellType,'CRB'));
X = [zscore(FR(inx)'),(CV(inx)'-mean(CV(inx)))/std(CV(inx),'omitnan')];
[coeff,scores,latent,tsquared,explained,mu] = pca(X);

for i = 1:length(inx)
    task_info(lines(inx(i))).crb_pc_score = scores(i,1);
    
end
save ([task_DB_path],'task_info')

