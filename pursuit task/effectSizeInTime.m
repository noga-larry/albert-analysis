%% Movement

clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 70;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 299;
raster_params.time_after = 2000;
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
    
        boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',BIN_SIZE)'*(1000/BIN_SIZE);
       
    for t=1:length(ts)
    [~,tbl,~,~] = anovan(response(t,:),{match_p,match_d},...
        'model','full','display','off');
    
    totVar = tbl{6,2};
    SSe = tbl{5,2};
    msw = tbl{5,5};
    N = length(response);
    
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
      
    omegaR(ii,t) = omega(tbl,2);
    omegaD(ii,t) = omega(tbl,3);
    omegaRD(ii,t) = omega(tbl,4);
    
    overAllExplained(ii,t) = (totVar - SSe)/totVar;
    end
end

%%

f = figure; hold on
ax1 = subplot(1,3,1); title('Direction'); hold on
ax2 = subplot(1,3,2);title('Reward'); hold on
ax3 = subplot(1,3,3); title('Interaction'); hold on


for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    axes(ax1)
    errorbar(ts,nanmean(omegaD(indType,:)),nanSEM(omegaD(indType,:)))
    xlabel('time')
    
    axes(ax2)
    errorbar(ts,nanmean(omegaR(indType,:)),nanSEM(omegaR(indType,:)))
    xlabel('time')
    
    axes(ax3)
    errorbar(ts,nanmean(omegaRD(indType,:)),nanSEM(omegaRD(indType,:)))
    xlabel('time')
end

legend(req_params.cell_type)

%% CUE

clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 70;
req_params.remove_question_marks = 1;

raster_params.align_to = 'cue';
raster_params.time_before = 299;
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
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_p = match_p(find(~boolFail))';
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',BIN_SIZE)'*(1000/BIN_SIZE);
       
    for t=1:length(ts)
    [~,tbl,~,~] = anovan(response(t,:),{match_p},...
        'model','full','display','off');
    
    totVar = tbl{end,2};
    SSe = tbl{end-1,2};
    msw = tbl{end-1,5};
    N = length(response);
    
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
      
    omegaR(ii,t) = omega(tbl,2);
    
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
raster_params.time_before = 299;
raster_params.time_after = 750;
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
            'partial',true, 'includeTime',true);
        
        omegaR(ii,t) = omegas(1).value;
        omegaD(ii,t) = omegas(2).value;
        omegaO(ii,t) = omegas(3).value;
        omegaInter(ii,t) = sum([omegas(3:6).value]);
        overAllExplained(ii,t) = omegas(end).value;
    end
end

%%

f = figure; hold on
ax1 = subplot(1,4,1); title('Direction'); hold on; ax1.YLim = [-0.05 0.1]
ax2 = subplot(1,4,2);title('Reward'); hold on; ax2.YLim = [-0.05 0.1]
ax3 = subplot(1,4,3); title('Outcome'); hold on; ax3.YLim = [-0.05 0.1]
ax4 = subplot(1,4,4); title('Interactions'); hold on; ax4.YLim = [-0.05 0.1]

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

legend(req_params.cell_type)



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
