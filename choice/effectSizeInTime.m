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

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 299;
raster_params.time_after = 800;
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
    
    boolFail = [data.trials.fail] | ~[data.trials.choice];
    ind = find(~boolFail); %| ~[data.trials.previous_completed];    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    
    match_d = match_d(1,:);
    match_p = (match_p(1,:)/25)*length(PROBABILITIES)+(match_p(2,:)/25);
    
    
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