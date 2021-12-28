%% Movement

clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'speed_2_dir_0,50,100';
req_params.ID = 4000:6000;
req_params.num_trials = 70;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 299;
raster_params.time_after = 750;
raster_params.smoothing_margins = 0;
bin_sz = 50;

ts = -raster_params.time_before:bin_sz:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaR = nan(length(cells),length(ts));
omegaD = nan(length(cells),length(ts));
omegaV = nan(length(cells),length(ts));
cellType = cell(length(cells),1);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_p = match_p(find(~boolFail))';
    [~,match_d] = getDirections (data);
    match_d = match_d(find(~boolFail))';
    [~,match_v] = getVelocities (data);
    match_v = match_v(find(~boolFail))';
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);
       
    for t=1:length(ts)
    [~,tbl,~,~] = anovan(response(t,:),{match_p,match_d, match_v},...
        'model','interaction','display','off');
    
    totVar = tbl{end,2};
    SSe = tbl{end-1,2};
    msw = tbl{end-1,5};
    N = length(response);
    
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
      
    omegaR(ii,t) = omega(tbl,2);
    omegaD(ii,t) = omega(tbl,3);
    omegaV(ii,t) = omega(tbl,4); 
    overAllExplained(ii,t) = (totVar - SSe)/totVar;
    end
end

%%

f = figure; hold on
ax1 = subplot(1,3,1); title('Direction'); hold on
ax2 = subplot(1,3,2);title('Reward'); hold on
ax3 = subplot(1,3,3); title('Velocity'); hold on

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    axes(ax1)
    errorbar(ts,nanmean(omegaD(indType,:)),nanSEM(omegaD(indType,:)))
    xlabel('time')
    
    axes(ax2)
    errorbar(ts,nanmean(omegaR(indType,:)),nanSEM(omegaR(indType,:)))
    xlabel('time')
    
    axes(ax3)
    errorbar(ts,nanmean(omegaV(indType,:)),nanSEM(omegaV(indType,:)))
    xlabel('time')
end

legend(req_params.cell_type)
