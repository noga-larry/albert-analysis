%% Movement

clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4797;
req_params.num_trials = 120;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 399;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 0;
BIN_SIZE = 50;

ts = -raster_params.time_before:BIN_SIZE:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaR = nan(length(cells),length(ts));
omegaD = nan(length(cells),length(ts));
cellType = cell(length(cells),1);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    cellID(ii) = data.info.cell_ID;
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    match_po = getPreviousOutcomes(data,ind,'omitNonIndexed',true);

    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',BIN_SIZE)'*(1000/BIN_SIZE);
       
    for t=1:length(ts)
        
        omegas = calOmegaSquare(response(t,:),...
            {match_p,match_d},...
            'partial',false, 'includeTime',false);
        
        omegaR(ii,t) = omegas(1).value;
        omegaD(ii,t) = omegas(2).value;
        omegaRD(ii,t) = omegas(3).value;
        overAllExplained(ii,t) = omegas(end).value;
    end
end

%%

f = figure; hold on
ax1 = subplot(1,3,1); title('Direction'); hold on
ax2 = subplot(1,3,2);title('Reward'); hold on
ax3 = subplot(1,3,3); title('Interaction'); hold on

h = cellID<inf


for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType) & h');
    
    axes(ax1)
    errorbar(ts,nanmean(omegaD(indType,:),1),nanSEM(omegaD(indType,:),1))
    xlabel('time')
    
    axes(ax2)
    errorbar(ts,nanmean(omegaR(indType,:),1),nanSEM(omegaR(indType,:),1))
    xlabel('time')
    
    axes(ax3)
    errorbar(ts,nanmean(omegaRD(indType,:),1),nanSEM(omegaRD(indType,:),1))
    xlabel('time')
end

legend(ax1,req_params.cell_type)
legend(ax2,req_params.cell_type)
legend(ax3,req_params.cell_type)

%% CUE

clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};

req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
%req_params.ID = 5455;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;

raster_params.align_to = 'cue';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;
BIN_SIZE = 50;

ts = -raster_params.time_before:BIN_SIZE:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaR = nan(length(cells),length(ts));
cellType = cell(length(cells),1);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    

    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    match_po = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',BIN_SIZE)'*(1000/BIN_SIZE);
    
    
    for t=1:length(ts)
        
        omegas = calOmegaSquare(response(t,:),...
            {match_p},...
            'partial',true, 'includeTime',false);
        
        omegaR(ii,t) = omegas(1).value;
        %omegaPO(ii,t) = omegas(2).value;
        overAllExplained(ii,t) = omegas(end).value;
    end
    
end

%%

f = figure; hold on

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    errorbar(ts,nanmean(omegaR(indType,:)),nanSEM(omegaR(indType,:)))
    xlabel('time')
    
end

legend(req_params.cell_type)

f = figure; hold on

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    errorbar(ts,nanmean(omegaPO(indType,:)),nanSEM(omegaPO(indType,:)))
    xlabel('time')
    
end

legend(req_params.cell_type)

%% Outcome

clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 100;
req_params.remove_question_marks = 1;

raster_params.align_to = 'reward';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;
BIN_SIZE = 50;

ts = -raster_params.time_before:BIN_SIZE:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaR = nan(length(cells),length(ts));
omegaD = nan(length(cells),length(ts));
omegaO = nan(length(cells),length(ts));
omegaInter = nan(length(cells),length(ts)); 
cellType = cell(length(cells),1);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    ind = find(~boolFail);
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',BIN_SIZE)'*(1000/BIN_SIZE);
    
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [match_o] = getOutcome (data,ind,'omitNonIndexed',true);
       
    for t=1:length(ts)
        
        omegas = calOmegaSquare(response(t,:),{match_p,match_d,match_o},...
            'partial',true, 'includeTime',false);
        
        omegaR(ii,t) = omegas(1).value;
        omegaD(ii,t) = omegas(2).value;
        omegaO(ii,t) = omegas(3).value;
        omegaInter(ii,t) = sum([omegas(5).value]);
        overAllExplained(ii,t) = omegas(end).value;
    end
end

%%

f = figure; hold on
ax1 = subplot(1,4,1); title('Direction'); hold on; ax1.YLim = [-0.05 0.1]
ax2 = subplot(1,4,2);title('Reward'); hold on; ax2.YLim = [-0.05 0.1]
ax3 = subplot(1,4,3); title('Outcome'); hold on; ax3.YLim = [-0.05 0.1]
ax4 = subplot(1,4,4); title('Prob*Outcome'); hold on; ax4.YLim = [-0.05 0.1]

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    axes(ax1)
    errorbar(ts,nanmean(omegaD(indType,:)),nanSEM(omegaD(indType,:)))
    xlabel('time')
    
    axes(ax2)
    errorbar(ts,nanmean(omegaR(indType,:)),nanSEM(omegaR(indType,:)))
    xlabel('time')
    
    axes(ax3)
    errorbar(ts,nanmean(omegaO(indType,:)),nanSEM(omegaO(indType,:)))
    xlabel('time')
    
    axes(ax4)
    errorbar(ts,nanmean(omegaInter(indType,:)),nanSEM(omegaInter(indType,:)))
    xlabel('time')
    
end

legend(ax1,req_params.cell_type)
legend(ax2,req_params.cell_type)
legend(ax3,req_params.cell_type)
legend(ax4,req_params.cell_type)



%% Histogram 

T = find(ts==1);
bins = linspace(-0.2,1,50);
f = figure; hold on
ax1 = subplot(1,4,1); title('Direction'); hold on
ax2 = subplot(1,4,2);title('Reward'); hold on
ax3 = subplot(1,4,3); title('Outcome'); hold on
ax4 = subplot(1,4,4); title('Interactions'); hold on

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    axes(ax1)
    plotHistForFC(omegaD(indType,T),bins)
    xlabel('Effect Size')
    
    axes(ax2)
    plotHistForFC(omegaR(indType,T),bins)
    xlabel('Effect Size')
    
    axes(ax3)
    plotHistForFC(omegaO(indType,T),bins)
    xlabel('Effect Size')
    
%     axes(ax4)
%     plotHistForFC(omegaInter(indType,T,inter),bins)
%     xlabel('Effect Size')
    
end

legend(req_params.cell_type)
