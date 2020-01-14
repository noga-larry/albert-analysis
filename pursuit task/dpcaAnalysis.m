
%% cue

supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 20;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;


ts = -raster_params.time_before:raster_params.time_after;


lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
rateLow = nan(length(cells),length(ts));
rateHigh = nan(length(cells),length(ts));


for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getPreviousCompleted(data,MaestroPath);
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    firingRates(ii,1,:) = raster2psth(rasterHigh,raster_params);
    firingRates(ii,2,:) = raster2psth(rasterLow,raster_params);

   
end

[W, V, whichMarg] = dpca(firingRates, 20);

% computing explained variance
explVar = dpca_explainedVariance(firingRates, W, V);

margNames = {'prob', 'time', 'prob*time'};
% a bit more informative plotting
dpca_plot(firingRates, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'time', ts,                        ...
    'timeEvents', 0,               ...
    'marginalizationNames', margNames);


%% movement

clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

directions = 0:45:315;
angles = [0:45:180];
ts = -raster_params.time_before:raster_params.time_after;
comparison_window = 100:300; % for TC

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);

    boolFail = [data.trials.fail];
    inxLow = find (match_p == 25 & (~boolFail));
    inxHigh = find (match_p == 75 & (~boolFail));
    
    [~,match_d] = getDirections(data);
    
    [TC,~,~] = getTC(data, directions,1:length(data.trials), comparison_window);
    [PD,indPD] = centerOfMass (TC, directions);
    
    for d = 1:length(angles)
        
        inx = find ((match_d == mod(PD+angles(d),360) | match_d == mod(PD-angles(d),360)) & (~boolFail));
        
        raster_High = getRaster(data,intersect(inx,inxHigh), raster_params);
        raster_Low = getRaster(data, intersect(inx,inxLow), raster_params);
        
        firingRates(ii,d,1,:) = raster2psth(raster_High,raster_params)-mean(TC);
        firingRates(ii,d,2,:) = raster2psth(raster_Low,raster_params)-mean(TC);
        
    end
 
end
 
[W, V, whichMarg] = dpca(firingRates, 20);

% computing explained variance
combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};

explVar = dpca_explainedVariance(firingRates, W, V,'combinedParams', combinedParams)

% a bit more informative plotting

margNames = {'Prob', 'Angle', 'Condition-independent', 'P/D Interaction'};

dpca_plot(firingRates, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'time', ts,...
    'marginalizationNames', margNames)


%% reward

clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

directions = 0:45:315;
angles = [0:45:180];
ts = -raster_params.time_before:raster_params.time_after;
comparison_window = 100:300; % for TC

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
     data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    indLowR = find (match_p == 25 & match_o & (~boolFail));
    indLowNR = find (match_p == 25 & (~match_o) & (~boolFail));
    indHighR = find (match_p == 75 & match_o & (~boolFail));
    indHighNR = find (match_p == 75 & (~match_o) & (~boolFail));
    
    rasterLowR = getRaster(data,indLowR,raster_params);
    rasterLowNR = getRaster(data,indLowNR,raster_params);
    rasterHighR = getRaster(data,indHighR,raster_params);
    rasterHighNR = getRaster(data,indHighNR,raster_params);
    
    firingRates(ii,1,1,:) = raster2psth(rasterLowR,raster_params);
    firingRates(ii,1,2,:) = raster2psth(rasterLowNR,raster_params);
    firingRates(ii,2,1,:) = raster2psth(rasterHighR,raster_params);
    firingRates(ii,2,2,:) = raster2psth(rasterHighNR,raster_params);
 
end
 

%%
[W, V, whichMarg] = dpca(firingRates, 20);

% computing explained variance
combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};

explVar = dpca_explainedVariance(firingRates, W, V,'combinedParams', combinedParams)

% a bit more informative plotting

margNames = {'Prob', 'Outcome', 'Condition-independent', 'P/O Interaction'};

dpca_plot(firingRates, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'time', ts,...
    'marginalizationNames', margNames)


