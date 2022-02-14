%% Movement

clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PROBABILITIES = 0:25:100;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'choice';
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;
req_params.num_trials = 100;

raster_params.align_to = 'reward';
raster_params.time_before = 1999;
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
    
    data = getBehavior(data, supPath);
    
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    boolFail = [data.trials.fail] | ~[data.trials.choice];
    ind = find(~boolFail); %| ~[data.trials.previous_completed];    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    match_o = getOutcome (data,ind,'omitNonIndexed',true);
    
    match_d = match_d(1,:);
    %match_p = (match_p(1,:)/25)*length(PROBABILITIES)+(match_p(2,:)/25);    
    match_p = match_p(1,:);
    
    raster = getRaster(data,ind,raster_params);
    response = downSampleToBins(raster',BIN_SIZE)'*(1000/BIN_SIZE);
       
    for t=1:length(ts)
        
        omegas = calOmegaSquare(response(t,:),...
            {match_p,match_d,match_o},...
            'partial',false, 'includeTime',false);
        
        omegaR(ii,t) = omegas(1).value;
        omegaD(ii,t) = omegas(2).value;
        omegaRD(ii,t) = omegas(3).value;
        omegaSup(ii,t) = omegas(5).value;
        overAllExplained(ii,t) = omegas(end).value;
    end
end

%%

f = figure; hold on
ax1 = subplot(1,4,1); title('Direction'); hold on
ax2 = subplot(1,4,2);title('Reward'); hold on
ax3 = subplot(1,4,3); title('Interaction'); hold on
ax4 = subplot(1,4,4); title('Suprise'); hold on

bool = cellID<inf

for i = 1:length(req_params.cell_type)
    
    indType = find(bool' & strcmp(req_params.cell_type{i}, cellType));
    
    axes(ax1)
    errorbar(ts,nanmean(omegaD(indType,:)),nanSEM(omegaD(indType,:)))
    xlabel('time')
    
    axes(ax2)
    errorbar(ts,nanmean(omegaR(indType,:)),nanSEM(omegaR(indType,:)))
    xlabel('time')
    
    axes(ax3)
    errorbar(ts,nanmean(omegaRD(indType,:)),nanSEM(omegaRD(indType,:)))
    xlabel('time')
    
    axes(ax4)
    errorbar(ts,nanmean(omegaSup(indType,:)),nanSEM(omegaSup(indType,:)))
    xlabel('time')
    
end

legend(req_params.cell_type)

%% Outcome


clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PROBABILITIES = 0:25:100;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'choice';
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;
req_params.num_trials = 100;

raster_params.align_to = 'reward';
raster_params.time_before = 799;
raster_params.time_after = 2000;
raster_params.smoothing_margins = 0;
BIN_SIZE = 50;

ts = -raster_params.time_before:BIN_SIZE:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaO = nan(length(cells),length(ts));
omegaD = nan(length(cells),length(ts));

cellType = cell(length(cells),1);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    
    data = getBehavior(data, supPath);
    
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    boolFail = [data.trials.fail] | ~[data.trials.choice];
    ind = find(~boolFail); %| ~[data.trials.previous_completed];    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [match_o] = getOutcome (data,ind,'omitNonIndexed',true);
    
    match_d = match_d(1,:);
    match_p = (match_p(1,:)/25)*length(PROBABILITIES)+(match_p(2,:)/25);    
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',BIN_SIZE)'*(1000/BIN_SIZE);
       
    for t=1:length(ts)
        
        omegas = calOmegaSquare(response(t,:),...
            {match_o,match_d},...
            'partial',false, 'includeTime',false);
        
        omegaO(ii,t) = omegas(1).value;
        omegaD(ii,t) = omegas(2).value;
        omegaRO(ii,t) = omegas(3).value;
        overAllExplained(ii,t) = omegas(end).value;
    end
end

%%

f = figure; hold on
ax1 = subplot(1,3,1); title('Direction'); hold on
ax2 = subplot(1,3,2);title('Outcome'); hold on
ax3 = subplot(1,3,3); title('Interaction'); hold on

bool = cellID<inf

for i = 1:length(req_params.cell_type)
    
    indType = find(bool' & strcmp(req_params.cell_type{i}, cellType));
    
    axes(ax1)
    errorbar(ts,nanmean(omegaD(indType,:)),nanSEM(omegaD(indType,:)))
    xlabel('time')
    
    axes(ax2)
    errorbar(ts,nanmean(omegaO(indType,:)),nanSEM(omegaO(indType,:)))
    xlabel('time')
    
    axes(ax3)
    errorbar(ts,nanmean(omegaRO(indType,:)),nanSEM(omegaRO(indType,:)))
    xlabel('time')
end

legend(req_params.cell_type)

%%
figure; hold on

t = 30;

bin_edges = -1:0.05:1;

ind = find(cellID>0);
for i = 1:length(req_params.cell_type)
    
    indType = intersect(ind,...
        find(strcmp(req_params.cell_type{i}, cellType)));
    plotHistForFC(omegaO(indType,t),bin_edges);
   
    
end
legend(req_params.cell_type)
sgtitle(['effect size, T: ' num2str(ts(t))])