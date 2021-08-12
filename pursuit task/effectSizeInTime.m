clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'PC ss|CRB';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 70;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 299;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0;
bin_sz = 50;

ts = -raster_params.time_before:bin_sz:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaR = nan(length(cells),length(ts));
omegaD = nan(length(cells),length(ts));
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
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);
       
    for t=1:length(ts)
    [~,tbl,~,~] = anovan(response(t,:),{match_p,match_d},...
        'model','full','display','off');
    
    totVar = tbl{6,2};
    SSe = tbl{5,2};
    msw = tbl{5,5};
    N = length(response);
    
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(tbl{dim,2}+(N-tbl{dim,3})*msw);
      
    omegaR(ii,t) = omega(tbl,2);
    omegaD(ii,t) = omega(tbl,3);
    omegaRD(ii,t) = omega(tbl,4);
    
    overAllExplained(ii,t) = (totVar - SSe)/totVar;
    end
end

%%

boolPC = strcmp('PC ss', cellType);
ind = find(boolPC);

figure;
subplot(3,1,1); hold on
title('Diretion')
plot(ts,omegaD(ind,:))
ylabel('omega')
xlabel('Time from motion')
plot(ts,nanmean(omegaD(ind,:)),'k','LineWidth',2)

subplot(3,1,2); hold on
title('Reward')
plot(ts,omegaR(ind,:))
ylabel('omega')
xlabel('Time from motion')
plot(ts,nanmean(omegaR(ind,:)),'k','LineWidth',2)

subplot(3,1,3); hold on
title('Reward*Direction Interaction')
plot(ts,omegaRD(ind,:))
ylabel('omega')
xlabel('Time from motion')
plot(ts,nanmean(omegaRD(ind,:)),'k','LineWidth',2)