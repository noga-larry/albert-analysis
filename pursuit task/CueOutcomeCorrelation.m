clear; clc
[task_info, supPath ,~,task_DB_path] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both");

raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    cellID(ii) = data.info.cell_ID;
    
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    % cue
    
    raster_params.align_to = 'cue';
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    cueResoponse(ii) = (mean(mean(rasterHigh)) - mean(mean(rasterLow)))*1000;
    
    % reward

    raster_params.align_to = 'reward';
    indR = find ( match_o & (~boolFail));
    indNR = find ((~match_o) & (~boolFail));
    
    rasterR = getRaster(data,indR,raster_params);
    rasterNR = getRaster(data,indNR,raster_params);
    
    rewardResoponse(ii) = (mean(mean(rasterR)) - mean(mean(rasterNR)))*1000;
end


%%
figure;
N = length(req_params.cell_type);
h = cellID<inf;

for i = 1:length(req_params.cell_type)
    
    subplot(2,ceil(N/2),i)  
    
    
    indType = find(strcmp(req_params.cell_type{i}, cellType)& h);
    scatter(cueResoponse(indType),rewardResoponse(indType)); hold on
    [r,p] = corr(cueResoponse(indType)',rewardResoponse(indType)'...
        ,'type','Spearman')
    
    xlabel('cue: 75-25');ylabel('reward: R-NR')
    
    %[r,p] = corr(cueResoponse(find(h))',rewardResoponse(find(h))','type','Spearman')
    equalAxis(); refline(1,0)
    title([req_params.cell_type{i} ', r = ' num2str(r) ', p = ' num2str(p)])
end

%% correlation bootstap

indType = find(strcmp('PC ss', cellType)& h);
scores = [zscore(rewardResoponse(indType));zscore(cueResoponse(indType))];
labels = zeros(1,length(indType));

indType = find(strcmp('SNR', cellType)& h);
scores = [scores,[zscore(rewardResoponse(indType));zscore(cueResoponse(indType))]];
labels = [labels,ones(1,length(indType))];

f = @(x) corr(x(1,:)',x(2,:)','type','Spearman');
p_val = permutationTest(scores,labels,10000,f,1)
%% spesific to prob

clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

prob = 75;

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 20;
req_params.remove_question_marks = 1;

raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 0;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    % cue
    raster_params.allign_to = 'cue';
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    cueResoponse(ii) = (mean(mean(rasterHigh)) - mean(mean(rasterLow)))*1000;
    
    % reward
    raster_params.allign_to = 'reward';
    indR = find (match_p == prob & match_o & (~boolFail));
    indNR = find (match_p == prob & (~match_o) & (~boolFail));
   
    rasterR = getRaster(data,indR,raster_params);
    rasterNR = getRaster(data,indNR,raster_params);
    
    rewardResoponse(ii) = (mean(mean(rasterR)) - mean(mean(rasterNR)))*1000;
end

figure;
scatter(cueResoponse,rewardResoponse)
xlabel('cue');ylabel('reward')
[r,p] = corr(cueResoponse',rewardResoponse','type','Spearman')

title (['r = ' num2str(r) ', p = ' num2str(p)])



