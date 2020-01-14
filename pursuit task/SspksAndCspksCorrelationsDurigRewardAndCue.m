% During Reward
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');


bool_task = ~cellfun(@isempty,regexp({task_info.task},'pursuit_8_dir_75and25'));
bool_type = ~cellfun(@isempty,regexp({task_info.cell_type},'PC cs'));
bool_grade = [task_info.grade] <= 7;
bool_nt = [task_info.num_trials] > 20;
bool_qm = cellfun(@isempty,regexp({task_info.cell_type},'?'));
IDCspks = [task_info(find(bool_qm& bool_task & bool_type & bool_grade &bool_nt)).cell_ID];

bool_type = ~cellfun(@isempty,regexp({task_info.cell_type},'PC ss'));
IDSspks = [task_info(find(bool_qm & bool_task & bool_type & bool_grade &bool_nt)).cell_ID];
cellIDs = intersect(IDSspks,IDCspks);

raster_params.allign_to = 'reward';
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
comparison_window = 100:300; % for TC
directions = 0:45:315;

req_params.task = 'pursuit_8_dir_75and25';
req_params.remove_question_marks = 1;



for ii = 1:length(cellIDs)
    req_params.ID = cellIDs(ii);
    req_params.cell_type = 'PC ss';
    
    line = findLinesInDB (task_info, req_params);
    path = findPathsToCells (supPath,task_info,line);
    dataSspk = importdata(path{:});
    req_params.cell_type = 'PC cs';
    line = findLinesInDB (task_info, req_params);
    path = findPathsToCells (supPath,task_info,line);
    dataCspk = importdata(path{:});
    
    % Cspk
    [~,match_p] = getProbabilities (dataCspk);
    [match_o] = getOutcome (dataCspk);
    boolFail = [dataCspk.trials.fail];
    
    indLowR = find (match_p == 25 & match_o & (~boolFail));
    indHighR = find (match_p == 75 & match_o & (~boolFail));
    
    rasterLowR = getRaster(dataCspk,indLowR,raster_params);
    rasterHighR = getRaster(dataCspk,indHighR,raster_params);
    
    psthLowR = raster2psth(rasterLowR,raster_params) ;
    psthHighR = raster2psth(rasterHighR,raster_params);
    
    resposeCspk(ii) = mean(psthLowR - psthHighR); 
    
    % Sspk
    [~,match_p] = getProbabilities (dataSspk);
    [match_o] = getOutcome (dataSspk);
    boolFail = [dataSspk.trials.fail];
    
    indLowR = find (match_p == 25 & match_o & (~boolFail));
    indHighR = find (match_p == 75 & match_o & (~boolFail));
    
    rasterLowR = getRaster(dataSspk,indLowR,raster_params);
    rasterHighR = getRaster(dataSspk,indHighR,raster_params);
    
    psthLowR = raster2psth(rasterLowR,raster_params);
    psthHighR = raster2psth(rasterHighR,raster_params);
    
    resposeSspk(ii) = mean(psthLowR - psthHighR); 
    
    
end


figure;
scatter(resposeCspk,resposeSspk)
[r,p] = corr(resposeCspk',resposeSspk','type','Spearman')


%%

% During cue
clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');


bool_task = ~cellfun(@isempty,regexp({task_info.task},'pursuit_8_dir_75and25'));
bool_type = ~cellfun(@isempty,regexp({task_info.cell_type},'PC cs'));
bool_grade = [task_info.grade] <= 7;
bool_nt = [task_info.num_trials] > 20;
bool_qm = cellfun(@isempty,regexp({task_info.cell_type},'?'));
IDCspks = [task_info(find(bool_qm& bool_task & bool_type & bool_grade &bool_nt)).cell_ID];

bool_type = ~cellfun(@isempty,regexp({task_info.cell_type},'PC ss'));
IDSspks = [task_info(find(bool_qm & bool_task & bool_type & bool_grade &bool_nt)).cell_ID];
cellIDs = intersect(IDSspks,IDCspks);

raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
comparison_window = 100:300; % for TC
directions = 0:45:315;

req_params.task = 'pursuit_8_dir_75and25';
req_params.remove_question_marks = 1;



for ii = 1:length(cellIDs)
    req_params.ID = cellIDs(ii);
    req_params.cell_type = 'PC ss';
    
    line = findLinesInDB (task_info, req_params);
    path = findPathsToCells (supPath,task_info,line);
    dataSspk = importdata(path{:});
    req_params.cell_type = 'PC cs';
    line = findLinesInDB (task_info, req_params);
    path = findPathsToCells (supPath,task_info,line);
    dataCspk = importdata(path{:});
    
    % Cspk
    [~,match_p] = getProbabilities (dataCspk);
    boolFail = [dataCspk.trials.fail];
    
    indLow = find (match_p == 25  & (~boolFail));
    indHigh = find (match_p == 75  & (~boolFail));
    
    rasterLow = getRaster(dataCspk,indLow,raster_params);
    rasterHigh = getRaster(dataCspk,indHigh,raster_params);
    
    psthLow = raster2psth(rasterLow,raster_params) ;
    psthHigh = raster2psth(rasterHigh,raster_params);
    
    resposeCspk(ii) = mean(psthLow - psthHigh); 
    
    % Sspk
    [~,match_p] = getProbabilities (dataSspk);
    boolFail = [dataSspk.trials.fail];
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    rasterLow = getRaster(dataSspk,indLow,raster_params);
    rasterHigh = getRaster(dataSspk,indHigh,raster_params);
   
    psthLow = raster2psth(rasterLow,raster_params);
    psthHigh = raster2psth(rasterHigh,raster_params);
    
    resposeSspk(ii) = mean(psthLow - psthHigh); 
    
    
end


figure;
scatter(resposeCspk,resposeSspk)
[r,p] = corr(resposeCspk',resposeSspk','type','Spearman')








