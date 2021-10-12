clear; clc
[task_info, supPath ,~,task_DB_path] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'CRB|PC';
req_params.task = 'speed_2_dir_0,50,100';
req_params.ID = 4000:6000;
req_params.num_trials = 50;
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
    raster_params.align_to = 'cue';
    indLow = find (match_p == 0 & (~boolFail));
    indHigh = find ((match_p == 50 | match_p == 100)& (~boolFail));
    
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    h(ii) = task_info(lines(ii)).cue_differentiating;
    cueResoponse(ii) = (mean(mean(rasterHigh)) - mean(mean(rasterLow)))*1000;
    
    % reward
    raster_params.align_to = 'reward';
    indR = find ( match_o & (~boolFail));
    indNR = find ((~match_o) & (~boolFail));
   
    rasterR = getRaster(data,indR,raster_params);
    rasterNR = getRaster(data,indNR,raster_params);
    
    rewardResoponse(ii) = (mean(mean(rasterR)) - mean(mean(rasterNR)))*1000;
end



figure;
scatter(cueResoponse,rewardResoponse); hold on
scatter(cueResoponse(find(h)),rewardResoponse(find(h)))
xlabel('cue: 0-(50/100)');ylabel('reward: R-NR')
[r,p] = corr(cueResoponse',rewardResoponse','type','Spearman')
%[r,p] = corr(cueResoponse(find(h))',rewardResoponse(find(h))','type','Spearman')
equalAxis(); refline(1,0)
title([req_params.cell_type ', r = ' num2str(r) ', p = ' num2str(p)])
